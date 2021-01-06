# frozen_string_literal: true

module Resolvers
  class InstanceSecurityDashboardResolver < BaseResolver
    type ::Types::InstanceSecurityDashboardType, null: true

    def resolve(**args)
      ::InstanceSecurityDashboard.new(current_user)
    end
  end
end
