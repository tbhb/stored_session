class StoredSession::LogSubscriber < ActiveSupport::LogSubscriber
  def initialize
    super
    @logger = logger || StoredSession.logger
  end

  attr_writer :logger

  def logger
    @logger ||= StoredSession.logger
  end

  def session_read(event)
    debug formatted_event(event, "Session Read", **event.payload.slice(:sid))
  end
  subscribe_log_level :session_read, :debug

  def session_write(event)
    debug formatted_event(event, "Session Write", **event.payload.slice(:sid))
  end
  subscribe_log_level :session_write, :debug

  def session_delete(event)
    debug formatted_event(event, "Session Delete", **event.payload.slice(:sid))
  end
  subscribe_log_level :session_delete, :debug

  private
    def formatted_event(event, operation, **)
      "  [StoredSession] #{operation} in #{formatted_duration(event)} (#{formatted_payload(**)})"
    end

    def formatted_duration(event)
      "%.1fms" % event.duration
    end

    def formatted_payload(**attributes)
      attributes.map { |k, v| "#{k}: #{v.inspect}" }.join(" | ")
    end
end
