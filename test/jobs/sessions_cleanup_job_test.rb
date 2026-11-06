require 'test_helper'

class SessionsCleanupJobTest < ActiveSupport::TestCase
  setup do
    @john = users(:john)
  end

  test "a fresh session gets the server-side TTL" do
    session = @john.sessions.create!

    assert_operator session.expires_at, :>, 29.days.since
    assert_operator session.expires_at, :<, 31.days.since
  end

  test "perform deletes only the expired rows" do
    live = @john.sessions.create!
    stale = @john.sessions.create!
    stale.update!(expires_at: 1.minute.ago)
    forever = @john.sessions.create!
    forever.update!(expires_at: nil) # nil means no expiry, fixtures rely on it

    Sessions::CleanupJob.new.perform

    assert_includes Session.all, live
    assert_includes Session.all, forever
    assert_not Session.exists?(stale.id)
  end

  # config/recurring.yml is only wiring until the dispatcher runs it;
  # validating through SolidQueue's own RecurringTask validations keeps the
  # entry honest (schedule parses, class exists) without booting a dispatcher.
  test "the recurring.yml entry schedules a valid task" do
    tasks = YAML.load_file(Rails.root.join('config/recurring.yml'), aliases: true)['production']
    entry = tasks.fetch('sessions_cleanup')

    task = SolidQueue::RecurringTask.from_configuration('sessions_cleanup', **entry.transform_keys(&:to_sym).slice(:class, :command, :args, :queue, :priority, :schedule))

    assert task.valid?, "recurring.yml entry invalid: #{task.errors.full_messages}"
    assert_equal 'Sessions::CleanupJob', task.class_name
    assert_operator task.next_time, :>, Time.current
  end
end
