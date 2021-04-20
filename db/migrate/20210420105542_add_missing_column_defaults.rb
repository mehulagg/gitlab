# frozen_string_literal: true

class AddMissingColumnDefaults < ActiveRecord::Migration[6.0]
  def up
    # This migration sets default column values where
    # missing/incorrect for long running instances that migrated from MySQL database.
    change_column_default :application_settings, :polling_interval_multiplier, 1.0

    change_column_default :broadcast_messages, :color, nil
    change_column_default :broadcast_messages, :font, nil

    with_lock_retries do
      change_column_default :issues, :title, nil
    end

    change_column_default :keys, :title, nil
    change_column_default :keys, :type, nil
    change_column_default :keys, :fingerprint, nil

    change_column_default :label_links, :target_type, nil

    change_column_default :labels, :title, nil
    change_column_default :labels, :color, nil

    change_column_default :members, :type, nil

    with_lock_retries do
      change_column_default :merge_request_diffs, :state, nil
    end

    with_lock_retries do
      change_column_default :merge_requests, :title, nil
    end

    change_column_default :milestones, :state, nil

    change_column_default :namespaces, :type, nil
    change_column_default :namespaces, :avatar, nil

    change_column_default :notes, :noteable_type, nil
    change_column_default :notes, :attachment, nil
    change_column_default :notes, :line_code, nil
    change_column_default :notes, :commit_id, nil
    change_column_default :notes, :system, false

    change_column_default :projects, :name, nil
    change_column_default :projects, :path, nil
    change_column_default :projects, :import_url, nil
    change_column_default :projects, :archived, false

    change_column_default :services, :type, nil
    change_column_default :services, :active, false

    change_column_default :snippets, :title, nil
    change_column_default :snippets, :file_name, nil
    change_column_default :snippets, :type, nil

    change_column_default :taggings, :taggable_type, nil
    change_column_default :taggings, :tagger_type, nil
    change_column_default :taggings, :context, nil

    change_column_default :tags, :name, nil

    with_lock_retries do
      change_column_default :users, :reset_password_token, nil
      change_column_default :users, :current_sign_in_ip, nil
      change_column_default :users, :last_sign_in_ip, nil
      change_column_default :users, :name, nil
      change_column_default :users, :admin, false
      change_column_default :users, :username, nil
      change_column_default :users, :can_create_group, true
      change_column_default :users, :can_create_team, true
      change_column_default :users, :state, nil
      change_column_default :users, :avatar, nil
      change_column_default :users, :confirmation_token, nil
      change_column_default :users, :unconfirmed_email, nil
      change_column_default :users, :hide_no_ssh_key, false
    end  

    change_column_default :web_hooks, :push_events, true
    change_column_default :web_hooks, :issues_events, false
    change_column_default :web_hooks, :merge_requests_events, false
    change_column_default :web_hooks, :tag_push_events, false
  end

  def down
    # no-op

    # Unable to revert because previous default column value
    # is unknown/not consistent between GitLab instances.
  end
end
