# frozen_string_literal: true

module Types
  class NoteSortEnum < BaseEnum
    graphql_name 'NoteSort'
    description 'Values for sorting notes'

    value 'CREATED_AT_ASC', 'Created date by ascending order.', value: :created_at_asc
    value 'CREATED_AT_DESC', 'Created date by descending order.', value: :created_at_desc
  end
end
