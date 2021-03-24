# frozen_string_literal: true

module EE
  module Members
    module InviteService
      extend ::Gitlab::Utils::Override

      private

      override :validate_emails!
      def validate_emails!
        super

        if invite_quota_exceeded?
          raise ::Members::InviteService::TooManyEmailsError,
                s_("AddMember|Invite limit of %{daily_invites} per day exceeded") %
                  { daily_invites: source.actual_limits.daily_invites }
        end
      end

      def invite_quota_exceeded?
        return unless source.actual_limits.daily_invites

        invite_count = ::Member.invite.created_today.in_hierarchy(source).count

        source.actual_limits.exceeded?(:daily_invites, invite_count + emails.count)
      end

      def after_execute(member:)
        super

        log_audit_event(member: member)
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
