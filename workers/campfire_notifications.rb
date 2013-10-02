class CampfireNotification
  include FanoutWorker

  subscribe 'account.create' do |ch, account|
    new(account, 'developers', 'hey').run
    new(account, 'general', 'hoe!').run
  end

  def initialize(account, room, msg)
    @account = account
    @room    = room
    @msg     = msg
  end

  def run
    p "Send cancellation notice '#{@msg}' to campfire room #{@room}"
  end
end
