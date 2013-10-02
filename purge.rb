require "json"
require "restclient"

docs = JSON[RestClient.get('http://localhost:5984/couch_logger/_all_docs')]["rows"]

docs.each do |doc|
  next if doc["id"] =~ /_design/

  RestClient.delete("http://localhost:5984/couch_logger/#{doc['id']}?rev=#{doc['value']['rev']}")

  p doc["id"]
end
