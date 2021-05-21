# frozen_string_literal: true

module Types
  module Ci
    class RunnerSortEnum < BaseEnum
      graphql_name 'CiRunnerSort'
      description 'Values for sorting runners'

      value 'CONTACTED_ASC', 'Ordered by contacted_at in ascending order.', value: :contacted_asc
      value 'CONTACTED_DESC', 'Ordered by contacted_at in descending order.', value: :contacted_desc
      value 'CREATED_ASC', 'Ordered by created_date in ascending order.', value: :created_date_asc
      value 'CREATED_DESC', 'Ordered by created_date in descending order.', value: :created_date_desc
    end
  end
end
