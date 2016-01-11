module ApiGuardian
  module Logging
    class Logger < ActiveSupport::Logger
      def initialize(*args)
        super
        @formatter = Formatter.new
      end

      class Formatter < ActiveSupport::Logger::SimpleFormatter
        def call(severity, _time, _progname, msg)
          response = '[' + 'ApiGuardian'.cyan + '] '

          request_id = ApiGuardian.current_request ? ApiGuardian.current_request.uuid : nil
          response += '[' + request_id.light_green + '] ' if request_id

          case severity
          when 'WARN'
            severity = severity.yellow
          when 'ERROR'
            severity = severity.light_red
          when 'FATAL'
            severity = severity.red
          when 'INFO'
            severity = severity.green
          end

          msg = msg.is_a?(String) ? msg : msg.inspect

          response += "[#{severity}] #{msg}\n"
          response
        end
      end
    end
  end
end
