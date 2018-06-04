module SmartSession
  class LogSubscriber < ActiveRecord::LogSubscriber

    # ActiveSupport::LogSubscriber.log_subscribers.delete_if{ |ls|
    #   ls.instance_of? SmartSession::LogSubscriber }

    def sql(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      payload = event.payload
      sql = payload[:sql].squeeze(' ')
      return unless (payload[:name] && payload[:name].start_with?('SmartSession') || sql.match(%r{update .sessions. }i))

      name = '%s (%.1fms) SmartSession-' % [payload[:name], event.duration]
      sql.sub!(%r{( SET \[data\] = N')([^']*)}) do |m| "#{Regexp.last_match[1]}<#{Regexp.last_match[2].length} bytes of session data>" end
      binds = nil

      unless (payload[:binds] || []).empty?
        binds = "  " + payload[:binds].map {|col, v|
          if col
            if col.binary?
              [col.name, "<#{v.bytesize} bytes of binary data>" ]
            else
              [col.name, v]
            end
          else
            [nil, v]
          end
        }.inspect
      end

      # if odd?
      #   name = color(name, CYAN, true)
      #   sql = color(sql, nil, true)
      # else
      name = color(name, MAGENTA, true)
      # end

      send(:debug, "  #{name}  #{sql}#{binds}")
    end

    attach_to :active_record

  end
end
