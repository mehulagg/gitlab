# frozen_string_literal: true

module EE
  module Emails
    module Members
      def member_access_granted_email_with_confirmation(member_source_type, member_id)
        @member_source_type = member_source_type
        @member_id = member_id
        @user = member.user

        return unless member_exists?

        member_email_with_layout(
          to: member.user.notification_email_for(notification_group),
          subject: subject("Welcome to GitLab"))
      end
    end
  end
end
