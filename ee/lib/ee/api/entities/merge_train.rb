# frozen_string_literal: true

module EE
  module API
    module Entities
      class MergeTrain < Grape::Entity
        expose :id
        expose :merge_request, using: ::API::Entities::MergeRequestSimple
        expose :user, using: ::API::Entities::UserBasic
        expose :pipeline, using: ::API::Entities::Ci::PipelineBasic
        expose :created_at
        expose :updated_at
        expose :target_branch
        expose :status_name, as: :status
        expose :merged_at
        expose :duration
      end
    end
  end
end
