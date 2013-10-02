module FanoutWorker
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def subscribe(routing_key)
      EventBus.subscribe(routing_key) do |*args|
        yield *args
      end
    end
  end
end
