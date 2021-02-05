# frozen_string_literal: true

module Emails
  module UserCap
    def user_cap_reached(user_id)
      user = User.find(user_id)
      email = user.notification_email

      @url_to_user_cap = 'https://docs.gitlab.com/ee/user/admin_area/settings/sign_up_restrictions.html#user-cap'
      @url_to_pending_users = 'https://docs.gitlab.com/ee/user/admin_area/approving_users.html'
      @url_to_approve = 'https://docs.gitlab.com/ee/user/admin_area/approving_users.html#approving-a-user'
      @url_to_docs = 'https://docs.gitlab.com/'
      @url_to_support = 'https://about.gitlab.com/support/'

      mail to: email, subject: _('Important information about usage on your GitLab instance')
    end
  end
end
