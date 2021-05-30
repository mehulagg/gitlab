# frozen_string_literal: true

class AddBotDocumentationLinks < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  disable_ddl_transaction!

  class User < ApplicationRecord
    self.table_name = 'users'

    include ::EachBatch

    USER_TYPE_SUPPORT_BOT = 1
    USER_TYPE_ALERT_BOT = 2
    USER_TYPE_VISUAL_REVIEW_BOT = 3
    USER_TYPE_MIGRATION_BOT = 7
    USER_TYPE_SECURITY_BOT = 8

    USER_TYPE_PROJECT_BOT = 6

    USER_TYPE_GHOST = 5

    scope :support_bots, -> { where(user_type: USER_TYPE_SUPPORT_BOT) }
    scope :alert_bots, -> { where(user_type: USER_TYPE_ALERT_BOT) }
    scope :visual_review_bots, -> { where(user_type: USER_TYPE_VISUAL_REVIEW_BOT) }
    scope :migration_bots, -> { where(user_type: USER_TYPE_MIGRATION_BOT) }
    scope :security_bots, -> { where(user_type: USER_TYPE_SECURITY_BOT) }

    scope :project_bots, -> { where(user_type: USER_TYPE_PROJECT_BOT) }

    scope :ghost_users, -> { where(user_type: USER_TYPE_GHOST) }

    scope :no_website_url, -> { where(website_url: '') }
  end

  def up
    User.reset_column_information

    User.support_bots.no_website_url.each_batch do |relation|
      relation.update_all(website_url: Gitlab::Routing.url_helpers.help_page_url('user/project/service_desk.md'))
    end
    User.alert_bots.no_website_url.each_batch do |relation|
      relation.update_all(website_url: Gitlab::Routing.url_helpers.help_page_url('operations/incident_management/alerts.md'))
    end
    User.visual_review_bots.no_website_url.each_batch do |relation|
      relation.update_all(website_url: Gitlab::Routing.url_helpers.help_page_url('ci/review_apps/index.md'))
    end
    User.migration_bots.no_website_url.each_batch do |relation|
      relation.update_all(website_url: Gitlab::Routing.url_helpers.help_page_url('development/internal_users.md'))
    end
    User.security_bots.no_website_url.each_batch do |relation|
      relation.update_all(website_url: Gitlab::Routing.url_helpers.help_page_url('user/application_security/security_bot/index.md'))
    end

    User.project_bots.no_website_url.each_batch do |relation|
      relation.update_all(website_url: Gitlab::Routing.url_helpers.help_page_url('security/token_overview.md'))
    end

    User.ghost_users.no_website_url.each_batch do |relation|
      relation.update_all(website_url: Gitlab::Routing.url_helpers.help_page_url('user/profile/account/delete_account.md'))
    end
  end

  def down
    # no-op
  end
end
