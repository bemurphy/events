class ModelWorker
  include FanoutWorker

  subscribe(/.+/) do |ch, attrs|
    puts "model feed #{ch} => #{attrs}"
  end
end
