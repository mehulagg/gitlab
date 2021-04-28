# frozen_string_literal: true

module Resolvers
  module Geo
    class LfsObjectRegistriesResolver < BaseResolver
      type ::Types::Geo::GeoNodeType.connection_type, null: true

      include RegistriesResolver
    end
  end
end
