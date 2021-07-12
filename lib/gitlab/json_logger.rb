# frozen_string_literal: true

module Gitlab
  class JsonLogger < ::Gitlab::Logger
    def self.file_name_noext
      raise NotImplementedError
    end

    def format_message(severity, timestamp, progname, message)
      data = default_attributes(severity, timestamp, progname, message)

      case message
      when String
        data[:message] = message
      when Hash
        data.merge!(message)
      end

      Gitlab::Json.dump(data) + "\n"
    end

    protected

    def default_attributes(severity, timestamp, progname, message)
      {
        :severity => severity,
        :time => timestamp.utc.iso8601(3),
        Labkit::Correlation::CorrelationId::LOG_KEY => Labkit::Correlation::CorrelationId.current_id
      }
    end
  end
end
