# frozen_string_literal: true

class MergeRequestUserEntity < Grape::Entity
  expose :user do |reviewer|
    API::Entities::UserBasic.represent(reviewer.reviewer)
  end

  expose :can_merge do |reviewer, options|
    options[:merge_request]&.can_be_merged_by?(reviewer.reviewer)
  end

  expose :reviewed
end

MergeRequestUserEntity.prepend_if_ee('EE::MergeRequestUserEntity')
