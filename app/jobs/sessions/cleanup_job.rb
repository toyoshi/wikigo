module Sessions
  # Recurring task (#138): sweeps the server-side sessions that the
  # permanent cookie left behind - nobody signs out a closed browser, so
  # without this the table only grows. Registered in config/recurring.yml;
  # the dispatcher's scheduler enqueues it on its cron schedule when
  # SOLID_QUEUE_MODE includes the scheduler.
  class CleanupJob < ApplicationJob
    def perform
      Session.expired.delete_all
    end
  end
end
