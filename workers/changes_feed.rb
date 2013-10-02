# require "bunny"

# conn = Bunny.new
# conn.start
# ch = conn.create_channel
# exchange = ch.topic('events', auto_delete: true)

# EventBus.subscribe(/.+\.(update|create|delete)\z/) do |*args|
#   model = args[1]
#   exchange.publish model.to_json, routing_key: args[0]
# end
