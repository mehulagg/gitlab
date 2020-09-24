# frozen_string_literal: true

class GeoNodePolicy < ::BasePolicy
  condition(:can_read_all_geo, scope: :user) { can?(:read_all_geo, :global) }

  rule { can_read_all_geo }.enable :read_geo_node
end
