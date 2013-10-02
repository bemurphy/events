require "./event_bus"
require "faker"
require "json/ext"
require "couchrest_model"

module ModelPub
  def self.included(base)
    base.send :include, ModelCallbacks

    base.send :after_create, :pub_after_create
    base.send :around_update, :pub_around_update
    base.send :after_destroy, :pub_after_destroy
  end

  module ModelCallbacks
    def pub_before_update
      @_pub_changes = changes.dup
    end

    def pub_after_create
      key = "#{self.class.name.downcase}.create"
      EventBus.publish(key, to_hash)
    end

    def pub_around_update
      pub_changes = changes.dup
      yield
      EventBus.publish("#{self.class.name.downcase}.update", to_hash, pub_changes)
    end

    def pub_after_destroy
      EventBus.publish("#{self.class.name.downcase}.delete", to_hash)
    end
  end
end

class Post < CouchRest::Model::Base
  include ModelPub

  property :title, String
  property :author, String
end

require "bunny"

conn = Bunny.new
conn.start
ch = conn.create_channel
exchange = ch.topic('events', auto_delete: true)

models = %w[account post]

EventBus.subscribe(/\A(#{models.join('|')})\.[a-z]+\z/) do |key, *args|
  doc = {attrs: args[0]}
  doc["changes"] = args[1] if args[1]
  exchange.publish doc.to_json, routing_key: "notifications.#{key}"
end

10.times {
  title  = Faker::Lorem.sentence
  author = Faker::Name.name

  post = Post.new(title: title, author: author)
  post.save
  post.title = 'foo' if rand(0) < 0.3 || true
  post.author = Faker::Name.name if rand(0) < 0.3 || true
  post.save
  post.destroy
}

class Account < CouchRest::Model::Base
  include ModelPub
  include ActiveModel::Observing

  property :admin_email, String
  property :plan_name, String
  property :canceled_at, Time

  def create(*)
    notify_observers(:before_create)
    r = super
    notify_observers(:after_create)
    r
  end

  def cancel
    self.canceled_at = Time.now.utc
    EventBus.publish('account.canceled', to_hash)
  end

  def cancel!
    cancel
    save
  end
end

class AccountObserver < ActiveModel::Observer
  def before_create(account)
    puts "Creating account #{account}"
  end

  def after_create(account)
    puts "Account #{account.id} created"
  end
end

Account.observers = :account_observer
AccountObserver.instance
Account.instantiate_observers


plans = %w[gold silver bronze platinum copper]
a = Account.create(admin_email: Faker::Internet.email, plan_name: plans.sample)
a.admin_email = Faker::Internet.email
a.plan_name = plans.sample
a.save
a.cancel!
a.destroy
