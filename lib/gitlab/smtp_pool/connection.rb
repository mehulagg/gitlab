# frozen_string_literal: true

module Gitlab
  module SMTPPool
    class Connection
      attr_accessor :settings

      DEFAULTS = {
        :address              => 'localhost',
        :port                 => 25,
        :domain               => 'localhost.localdomain',
        :user_name            => nil,
        :password             => nil,
        :authentication       => nil,
        :enable_starttls      => nil,
        :enable_starttls_auto => true,
        :openssl_verify_mode  => nil,
        :ssl                  => nil,
        :tls                  => nil,
        :open_timeout         => nil,
        :read_timeout         => nil
      }

      def initialize(values)
        @smtp_session = nil
        self.settings = DEFAULTS.merge(values)
      end

      def smtp_session
        return start_smtp_session if @smtp_session.nil? || !@smtp_session.started?
        return @smtp_session if reset_smtp_session

        finish_smtp_session
        start_smtp_session
      end

      private

      def start_smtp_session
        @smtp_session = build_smtp_session.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication])
      end

      def reset_smtp_session
        !@smtp_session.instance_variable_get(:@error_occurred) && @smtp_session.rset.success?
      rescue Net::SMTPError, IOError
        false
      end

      def finish_smtp_session
        @smtp_session.finish
      rescue IOError
      ensure
        @smtp_session = nil
      end

      def build_smtp_session
        Net::SMTP.new(settings[:address], settings[:port]).tap do |smtp|
          if settings[:tls] || settings[:ssl]
            if smtp.respond_to?(:enable_tls)
              smtp.enable_tls(ssl_context)
            end
          elsif settings[:enable_starttls]
            if smtp.respond_to?(:enable_starttls)
              smtp.enable_starttls(ssl_context)
            end
          elsif settings[:enable_starttls_auto]
            if smtp.respond_to?(:enable_starttls_auto)
              smtp.enable_starttls_auto(ssl_context)
            end
          end

          smtp.open_timeout = settings[:open_timeout] if settings[:open_timeout]
          smtp.read_timeout = settings[:read_timeout] if settings[:read_timeout]
        end
      end

      # Allow SSL context to be configured via settings, for Ruby >= 1.9
      # Just returns openssl verify mode for Ruby 1.8.x
      def ssl_context
        openssl_verify_mode = settings[:openssl_verify_mode]

        if openssl_verify_mode.kind_of?(String)
          openssl_verify_mode = OpenSSL::SSL.const_get("VERIFY_#{openssl_verify_mode.upcase}")
        end

        context = Net::SMTP.default_ssl_context
        context.verify_mode = openssl_verify_mode if openssl_verify_mode
        context.ca_path = settings[:ca_path] if settings[:ca_path]
        context.ca_file = settings[:ca_file] if settings[:ca_file]
        context
      end
    end
  end
end
