# frozen_string_literal: true

module Types
  class ReleaseSortEnum < SortEnum
    graphql_name 'ReleaseSort'
    description 'Values for sorting releases'

    value 'CREATED_AT_ASC', 'Created at date by ascending order', value: :created_at_asc
    value 'CREATED_AT_DESC', 'Created at date by descending order', value: :created_at_desc
    value 'RELEASED_AT_ASC', 'Released at date by ascending order', value: :released_at_asc
    value 'RELEASED_AT_DESC', 'Released at date by descending order', value: :released_at_desc
  end
end
