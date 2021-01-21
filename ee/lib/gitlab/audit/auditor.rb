# frozen_string_literal: true

module Gitlab
  module Audit
    class Auditor
      # Record audit events for block
      #
      # @param [Hash] context
      # @option context [String] :name the operation name to be audited, used for error tracking
      # @option context [User] :author the user who authors the change
      # @option context [User, Project, Group] :scope the scope which audit event belongs to
      # @option context [Object] :target the target object being audited
      # @option context [Object] :ip_address the request IP address
      #
      # @example Wrap operation to be audit logged
      #
      #   Gitlab::Audit::Auditor.audit(context) do
      #     service.execute
      #   end
      #
      # @return result of block execution
      def self.audit(context)
        auditor = new(context)

        auditor.audit { yield }
      end

      def initialize(context)
        @context = context

        @name = @context.fetch(:name, 'audit_operation')
        @author = @context.fetch(:author)
        @scope = @context.fetch(:scope)
        @target = @context.fetch(:target)
        @ip_address = @context.fetch(:ip_address, nil)
      end

      def audit
        ::Gitlab::Audit::EventQueue.begin!

        return_value = yield

        record

        return_value
      ensure
        ::Gitlab::Audit::EventQueue.end!
      end

      private

      def record
        events = ::Gitlab::Audit::EventQueue.current.reverse.map(&method(:build_event))

        log_to_database(events)
        log_to_file(events)
      end

      def build_event(message)
        AuditEvents::BuildService.new(
          author: @author,
          scope: @scope,
          target: @target,
          ip_address: @ip_address,
          message: message
        ).execute
      end

      def log_to_database(events)
        AuditEvent.bulk_insert!(events)
      rescue ActiveRecord::RecordInvalid => error
        ::Gitlab::ErrorTracking.track_exception(error, audit_operation: @name)
      end

      def log_to_file(events)
        file_logger = ::Gitlab::AuditJsonLogger.build

        events.each { |event| file_logger.info(event.as_json) }
      end
    end
  end
end
