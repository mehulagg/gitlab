# frozen_string_literal: true

module Resolvers
  module AppSec
    module Dast
      class ProfileResolver < BaseResolver
        include LooksAhead

        alias_method :project, :object

        type ::Types::Dast::ProfileType.connection_type, null: true

        def resolve_with_lookahead(**args)
          apply_lookahead(find_dast_profiles(args))
        end

        private

        def preloads
          {
            dast_site_profile: [:dast_site_profiles],
            dast_scanner_profile: [:dast_scanner_profiles]
          }
        end

        def find_dast_profiles(args)
          ::Dast::ProfilesFinder.new(project_id: object.id).execute
        end
      end
    end
  end
end
