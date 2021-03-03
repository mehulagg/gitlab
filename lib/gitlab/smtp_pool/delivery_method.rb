# frozen_string_literal: true

module Gitlab
  module SMTPPool
    class DeliveryMethod
      class << self
        def pool
          @pool ||= ConnectionPool.new(size: pool_size) { ::Gitlab::SMTPPool::Connection.new(settings) }
        end

        def pool_size
          Gitlab::Runtime.max_threads
        end

        def settings
          ActionMailer::Base.smtp_pool_settings
        end
      end

      def initialize(settings)
      end

      def deliver!(mail)
        response = self.class.pool.with do |conn|
          Mail::SMTPConnection.new(:connection => conn.smtp_session, :return_response => true).deliver!(mail)
        end

        self.class.settings[:return_response] ? response : self
      end
    end
  end
end
