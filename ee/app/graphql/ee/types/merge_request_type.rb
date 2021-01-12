# frozen_string_literal: true

module EE
  module Types
    module MergeRequestType
      extend ActiveSupport::Concern

      prepended do
        field :approved, GraphQL::BOOLEAN_TYPE, method: :approved?, null: false, calls_gitaly: true,
              description: 'Indicates if the merge request has all the required approvals. Returns true if no required approvals are configured.'
        field :approvals_left, GraphQL::INT_TYPE, null: true, calls_gitaly: true,
              description: 'Number of approvals left'
        field :approvals_required, GraphQL::INT_TYPE, null: true,
              description: 'Number of approvals required'
        field :merge_trains_count, GraphQL::INT_TYPE, null: true,
              description: ''
      end

      def merge_trains_count
        return unless object.target_project.merge_trains_enabled?

        MergeTrain.total_count_in_train(object)
      end
    end
  end
end
