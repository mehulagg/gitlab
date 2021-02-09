# frozen_string_literal: true

class LicensesListSerializer < BaseSerializer
  include WithPagination

  entity LicensesListEntity
end
