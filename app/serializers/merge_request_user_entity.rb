# frozen_string_literal: true

class MergeRequestUserEntity < ::API::Entities::UserBasic
  expose :can_merge do |reviewer, options|
    options[:merge_request]&.can_be_merged_by?(reviewer)
  end

  expose :reviewed do |reviewer, options|
    options[:merge_request]&.merge_request_reviewers.find_by_user_id(reviewer.id)&.reviewed
  end
end

MergeRequestUserEntity.prepend_if_ee('EE::MergeRequestUserEntity')
