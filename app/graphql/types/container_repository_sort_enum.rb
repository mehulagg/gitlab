# frozen_string_literal: true

module Types
  class ContainerRepositorySortEnum < SortEnum
    graphql_name 'ContainerRepositorySort'
    description 'Values for sorting container repository'

    value 'NAME_ASC', 'Name by ascending order', value: :name_at_asc
    value 'NAME_DESC', 'Name by descending order', value: :name_at_desc
  end
end
