# frozen_string_literal: true

module Types
  module Packages
    class PackageSortEnum < BaseEnum
      graphql_name 'PackageSort'
      description 'Values for sorting package'

      value 'CREATED_DESC', 'Created at descending order.', value: :created_desc
      value 'CREATED_ASC', 'Created at ascending order.', value: :created_asc
      value 'NAME_DESC', 'Name by descending order.', value: :name_desc
      value 'NAME_ASC', 'Name by ascending order.', value: :name_asc
      value 'VERSION_DESC', 'Version by descending order.', value: :version_desc
      value 'VERSION_ASC', 'Version by ascending order.', value: :version_asc
      value 'TYPE_DESC', 'Type by descending order.', value: :type_desc
      value 'TYPE_ASC', 'Type by ascending order.', value: :type_asc
    end
  end
end
