# frozen_string_literal: true

module Types
  class SortEnum < BaseEnum
    graphql_name 'Sort'
    description 'Common sort values'

    value 'UPDATED_DESC', 'Updated at descending order.', value: :updated_desc
    value 'UPDATED_ASC', 'Updated at ascending order.', value: :updated_asc
    value 'CREATED_DESC', 'Created at descending order.', value: :created_desc
    value 'CREATED_ASC', 'Created at ascending order.', value: :created_asc
  end
end
