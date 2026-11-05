# Rails 8.1 Structured Event Reporter
#
# Provides a unified interface for emitting structured events.
#
# Usage:
#   Rails.event.notify("user.signup", user_id: current_user.id)
#   Rails.event.tagged("wiki") { Rails.event.notify("page.created", page_id: @page.id) }
#   Rails.event.set_context(request_id: request.request_id)

class EventLogSubscriber
  def emit(event)
    payload = event[:payload].map { |key, value| "#{key}=#{value}" }.join(" ")
    source = event[:source_location]
    tags = event[:tags].to_a.map { |tag| "[#{tag}]" }.join
    log = "#{tags}[#{event[:name]}] #{payload} at #{source[:filepath]}:#{source[:lineno]}"
    Rails.logger.info(log)
  end
end

Rails.application.configure do
  config.after_initialize do
    Rails.event.subscribe(EventLogSubscriber.new)
  end
end
