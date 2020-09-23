# frozen_string_literal: true

module EE
  module API
    module Entities
      class GroupPushRule < Grape::Entity
        expose :id, :created_at
        expose :commit_message_regex, :commit_message_negative_regex, :branch_name_regex, :deny_delete_tag
        expose :member_check, :prevent_secrets, :author_email_regex
        expose :file_name_regex, :max_file_size
        expose :commit_committer_check, if: lambda { |push_rule| push_rule.available?(:commit_committer_check) }
        expose :reject_unsigned_commits, if: lambda { |push_rule| push_rule.available?(:reject_unsigned_commits) }
      end
    end
  end
end
