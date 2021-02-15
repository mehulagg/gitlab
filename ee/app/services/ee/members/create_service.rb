# frozen_string_literal: true

module EE
  module Members
    module CreateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(source)
        if invite_quota_exceeded?(source, user_ids)
          return error(s_("AddMember|Invite limit of %{daily_invites} per day exceeded") % { daily_invites: source.actual_limits.daily_invites })
        end

        super(source)
      end

      def after_execute(member:)
        super

        log_audit_event(member: member)
      end

      private

      def log_audit_event(member:)
        ::AuditEventService.new(
          current_user,
          member.source,
          action: :create
        ).for_member(member).security_event
      end

      def invite_quota_exceeded?(source, user_ids)
        return unless source.actual_limits.daily_invites

        invite_count = ::Member.invite.created_today.in_hierarchy(source).count

        source.actual_limits.exceeded?(:daily_invites, invite_count + user_ids.count)
      end
    end
  end
end
