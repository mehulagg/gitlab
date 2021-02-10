# frozen_string_literal: true

class DependencyListSerializer < BaseSerializer
  include WithPagination

  entity DependencyListEntity
end
