require 'test_helper'

class ApplicationMailerTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries = []
    Setting[:email_subject_prefix] = '[foreman-production]'

    User.current = users :admin

    @options = {}
    @options[:env] = @env
    @options[:user] = User.current.id

    HostMailer.summary(@options).deliver

    @mail = ActionMailer::Base.deliveries.first
  end

  test "foreman server header is set" do
    assert_equal @mail.header['X-Foreman-Server'].to_s, 'foreman.some.host.fqdn'
  end

  test "foreman subject prefix is attached" do
    assert_match /^\[foreman-production\]/, @mail.subject
  end
end
