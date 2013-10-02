require "restclient"
require "json"
require "benchmark"
require "redis"

$redis ||= Redis.new

class CouchLogger
  include FanoutWorker

  subscribe(/.+/) do |*args|
    doc = {ch: args[0], attrs: args[1]}
    doc["changes"] = args[2] if args[2]
    puts doc
    $redis.lpush('log', doc.to_json)
  end
end
