# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddDefaultTrueRequireAdminApprovalAfterUserSignupToApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    change_column_default :application_settings, :require_admin_approval_after_user_signup, from: false, to: true
  end
end
