# frozen_string_literal: true

class DashboardEnvironmentsSerializer < BaseSerializer
  include WithPagination

  entity DashboardEnvironmentsProjectEntity
end
