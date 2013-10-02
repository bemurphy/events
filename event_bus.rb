require "active_support/all"
require "singleton"

class EventBus
  include Singleton

  class << self
    def subscribe(pat, &block)
      instance.subscribe(pat, &block)
    end

    def publish(key, *args)
      instance.publish(key, *args)
    end

    def subscribe_prefix(prefix, &block)
      instance.subscribe_prefix(prefix, &block)
    end

    def turn_on
      instance.turn_on
    end

    def turn_off
      instance.turn_off
    end
  end

  def initialize
    @events = ActiveSupport::Notifications::Fanout.new
    turn_on
  end

  def turn_on
    @on = true
  end

  def turn_off
    @on = false
  end

  def subscribe(pat, &block)
    @events.subscribe(pat, &block)
  end

  def subscribe_prefix(prefix, &block)
    pat = /\A#{prefix}\./
    @events.subscribe(pat, &block)
  end

  def publish(key, *args)
    if @on
      @events.publish(key, *args)
    end
  end
end

