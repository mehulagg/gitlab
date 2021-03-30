# frozen_string_literal: true

require 'connection_pool'
require 'mail/smtp_pool/connection'

module Mail
  class SMTPPool
    @pool = {}
    @mutex = Mutex.new

    DEFAULTS = {
      pool_size: 5,
      pool_timeout: 5
    }.freeze

    class << self
      def pool(settings)
        @pool[key_for_settings(settings)] || create_pool(settings)
      end

      def shutdown_pool(settings)
        @mutex.synchronize do
          pool = @pool[key_for_settings(settings)]

          return unless pool

          pool.shutdown { |conn| conn.finish }
          @pool[key_for_settings(settings)] = nil
        end
      end

      private

      def create_pool(settings)
        @mutex.synchronize do
          pool_key = key_for_settings(settings)

          return @pool[pool_key] if @pool[pool_key]

          @pool[pool_key] = ConnectionPool.new(size: settings[:pool_size], timeout: settings[:pool_timeout]) do
            smtp_settings = settings.dup
            DEFAULTS.keys.each { |pool_setting| smtp_settings.delete(pool_setting) }

            Mail::SMTPPool::Connection.new(smtp_settings)
          end
        end
      end

      def key_for_settings(settings)
        settings.hash
      end
    end

    attr_accessor :settings

    def initialize(settings)
      self.settings = DEFAULTS.merge(settings)
    end

    def deliver!(mail)
      self.class.pool(settings).with do |conn|
        conn.deliver!(mail)
      end
    end

    def finish
      self.class.shutdown_pool(settings)
    end
  end
end
