# frozen_string_literal: true

module Types
  class EpicSortEnum < BaseEnum
    graphql_name 'EpicSort'
    description 'Roadmap sort values'

    value 'start_date_desc', 'Start date at descending order'
    value 'start_date_asc', 'Start date at ascending order'
    value 'end_date_desc', 'End date at descending order'
    value 'end_date_asc', 'End date at ascending order'
  end
end
