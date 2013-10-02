EventBus.subscribe('account.create') do |channel, account|
  p "Send account.create notice to segmentio"
end

