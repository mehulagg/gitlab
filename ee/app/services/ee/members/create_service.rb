# frozen_string_literal: true

module EE
  module Members
    module CreateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(source)
        super.tap do
          update_gitlab_subscription(source)
        end
      end

      override :after_execute
      def after_execute(member:)
        super

        log_audit_event(member: member)
      end

      private

      def update_gitlab_subscription(membershipable)
        ::Gitlab::Subscription::MaxSeatsUpdater.update(membershipable)
      end

      def log_audit_event(member:)
        ::AuditEventService.new(
          current_user,
          member.source,
          action: :create
        ).for_member(member).security_event
      end
    end
  end
end
