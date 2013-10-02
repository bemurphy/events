class BillingNotification
  include FanoutWorker

  subscribe 'account.canceled' do |ch, account|
    new(account).run
  end

  def initialize(account)
    @account = account
  end

  def run
    p "Send cancellation email to Jim"
  end
end
