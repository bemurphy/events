require "restclient"
require "json"
require "benchmark"
require "redis"

# The time to sleep between grabbing entries
# for a bulk update
MAX_SLEEP = 3

$redis ||= Redis.new

url = "http://localhost:5984/couch_logger/_bulk_docs"

loop do
  docs = []

  while (raw_data = $redis.rpop('log'))
    created = Time.now.to_i
    data = JSON[raw_data]
    p data
    doc = {routing_key: data["ch"], created: created, attrs: data["attrs"]}
    doc["changes"] = data["changes"] if data["changes"]
    docs << doc
  end

  if docs.length > 0
    begin
      RestClient.post url, {docs: docs}.to_json, content_type: 'application/json'
      puts "Wrote #{docs.length} docs to couch"
    rescue => e
      p e
      raise e
    end
  end

  n = MAX_SLEEP
  # If there's lots of docs, sleep less to catch up
  if docs.length > 2000
    n = (n / 3.0).to_i
  end

  puts "Sleeping #{n}..."
  sleep n
end
