# frozen_string_literal: true

module EE
  module Types
    module IssueConnectionType
      extend ActiveSupport::Concern

      prepended do
        field :weight, GraphQL::INT_TYPE, null: false, description: 'Total weight of issues collection'
      end

      def weight
        # rubocop: disable CodeReuse/ActiveRecord
        object.items.sum(:weight)
        # rubocop: enable CodeReuse/ActiveRecord
      end
    end
  end
end
