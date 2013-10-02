require "bunny"
require "json"
require "./event_bus"
require "./fanout_worker"

Dir["./workers/**/*.rb"].each { |rb| require rb }
# require "./workers/couch_logger"

conn = Bunny.new
conn.start
ch = conn.create_channel

x = ch.topic('events', auto_delete: true)
ch.queue('#.#').bind(x, routing_key: '#.#').subscribe(block: true) do |delivery_info, properties, payload|
  key = delivery_info.routing_key.sub(/\Anotifications\./, '')
  data = JSON[payload]
  EventBus.publish(key, data["attrs"], data["changes"])
end
