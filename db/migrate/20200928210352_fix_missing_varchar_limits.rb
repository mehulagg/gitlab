# frozen_string_literal: true

class FixMissingVarcharLimits < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    change_column :appearances, :header_logo, :text
    change_column :appearances, :logo, :text
    change_column :appearances, :title, :text

    change_column :application_settings, :after_sign_out_path, :text
    change_column :application_settings, :home_page_url, :text

    change_column :approvers, :target_type, :text

    change_column :audit_events, :entity_type, :text
    change_column :audit_events, :type, :text

    change_column :audit_events_part_5fc467ac26, :entity_type, :text
    change_column :audit_events_part_5fc467ac26, :type, :text

    change_column :backup_labels, :color, :text
    change_column :backup_labels, :title, :text

    change_column :broadcast_messages, :color, :text
    change_column :broadcast_messages, :font, :text

    change_column :ci_builds, :description, :text
    change_column :ci_builds, :name, :text
    change_column :ci_builds, :ref, :text
    change_column :ci_builds, :stage, :text
    change_column :ci_builds, :status, :text
    change_column :ci_builds, :target_url, :text
    change_column :ci_builds, :type, :text

    change_column :ci_pipelines, :before_sha, :text
    change_column :ci_pipelines, :ref, :text
    change_column :ci_pipelines, :sha, :text

    change_column :ci_runners, :architecture, :text
    change_column :ci_runners, :description, :text
    change_column :ci_runners, :name, :text
    change_column :ci_runners, :platform, :text
    change_column :ci_runners, :revision, :text
    change_column :ci_runners, :token, :text
    change_column :ci_runners, :version, :text

    change_column :ci_triggers, :token, :text

    change_column :ci_variables, :encrypted_value_iv, :text
    change_column :ci_variables, :encrypted_value_salt, :text

    change_column :emails, :email, :text

    change_column :identities, :extern_uid, :text
    change_column :identities, :provider, :text

    change_column :issues, :title, :text

    change_column :keys, :fingerprint, :text
    change_column :keys, :title, :text
    change_column :keys, :type, :text

    change_column :label_links, :target_type, :text

    change_column :labels, :color, :text
    change_column :labels, :title, :text

    change_column :ldap_group_links, :cn, :text
    change_column :ldap_group_links, :provider, :text

    change_column :lfs_objects, :file, :text
    change_column :lfs_objects, :oid, :text

    change_column :members, :invite_email, :text
    change_column :members, :invite_token, :text
    change_column :members, :source_type, :text
    change_column :members, :type, :text

    change_column :merge_request_diffs, :state, :text

    change_column :merge_requests, :merge_status, :text, default: 'unchecked'
    change_column :merge_requests, :source_branch, :text
    change_column :merge_requests, :target_branch, :text
    change_column :merge_requests, :title, :text

    change_column :milestones, :state, :text
    change_column :milestones, :title, :text

    change_column :namespaces, :avatar, :text
    change_column :namespaces, :description, :text, default: ''
    change_column :namespaces, :name, :text
    change_column :namespaces, :path, :text
    change_column :namespaces, :type, :text

    change_column :notes, :attachment, :text
    change_column :notes, :commit_id, :text
    change_column :notes, :line_code, :text
    change_column :notes, :noteable_type, :text

    change_column :oauth_access_grants, :scopes, :text, default: ''
    change_column :oauth_access_grants, :token, :text

    change_column :oauth_access_tokens, :refresh_token, :text
    change_column :oauth_access_tokens, :scopes, :text
    change_column :oauth_access_tokens, :token, :text

    change_column :oauth_applications, :name, :text
    change_column :oauth_applications, :owner_type, :text
    change_column :oauth_applications, :scopes, :text, default: ''
    change_column :oauth_applications, :secret, :text
    change_column :oauth_applications, :uid, :text

    change_column :projects, :avatar, :text
    change_column :projects, :import_source, :text
    change_column :projects, :import_type, :text
    change_column :projects, :import_url, :text
    change_column :projects, :name, :text
    change_column :projects, :path, :text

    change_column :protected_branches, :name, :text

    change_column :push_rules, :author_email_regex, :text
    change_column :push_rules, :commit_message_regex, :text
    change_column :push_rules, :delete_branch_regex, :text
    change_column :push_rules, :file_name_regex, :text
    change_column :push_rules, :force_push_regex, :text

    change_column :releases, :tag, :text

    change_column :schema_migrations, :version, :text

    change_column :sent_notifications, :commit_id, :text
    change_column :sent_notifications, :line_code, :text
    change_column :sent_notifications, :noteable_type, :text
    change_column :sent_notifications, :reply_key, :text

    change_column :services, :type, :text

    change_column :snippets, :file_name, :text
    change_column :snippets, :title, :text
    change_column :snippets, :type, :text

    change_column :subscriptions, :subscribable_type, :text

    change_column :taggings, :context, :text
    change_column :taggings, :taggable_type, :text
    change_column :taggings, :tagger_type, :text

    change_column :tags, :name, :text

    change_column :users, :avatar, :text
    change_column :users, :confirmation_token, :text
    change_column :users, :current_sign_in_ip, :text
    change_column :users, :email, :text, default: ''
    change_column :users, :encrypted_otp_secret, :text
    change_column :users, :encrypted_otp_secret_iv, :text
    change_column :users, :encrypted_otp_secret_salt, :text
    change_column :users, :encrypted_password, :text, default: ''
    change_column :users, :last_sign_in_ip, :text
    change_column :users, :linkedin, :text, default: ''
    change_column :users, :location, :text
    change_column :users, :name, :text
    change_column :users, :notification_email, :text
    change_column :users, :public_email, :text, default: ''
    change_column :users, :reset_password_token, :text
    change_column :users, :skype, :text, default: ''
    change_column :users, :state, :text
    change_column :users, :twitter, :text, default: ''
    change_column :users, :unconfirmed_email, :text
    change_column :users, :username, :text
    change_column :users, :website_url, :text, default: ''

    change_column :web_hooks, :type, :text, default: 'ProjectHook'
  end

  def down
    # no op
  end
end
