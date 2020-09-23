# frozen_string_literal: true

module EE
  module API
    module Entities
      class ProjectPushRule < Grape::Entity
        extend ::API::Entities::EntityHelpers
        expose :id, :project_id, :created_at
        expose :commit_message_regex, :commit_message_negative_regex, :branch_name_regex, :deny_delete_tag
        expose :member_check, :prevent_secrets, :author_email_regex
        expose :file_name_regex, :max_file_size
        expose_restricted :commit_committer_check, &:project
        expose_restricted :reject_unsigned_commits, &:project
      end
    end
  end
end
