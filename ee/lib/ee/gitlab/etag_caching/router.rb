# frozen_string_literal: true

module EE
  module Gitlab
    module EtagCaching
      module Router
        EE_ROUTES = [
          ::Gitlab::EtagCaching::Router::Route.new(
            %r(^/groups/#{::Gitlab::PathRegex.full_namespace_route_regex}/-/epics/\d+/notes\z),
            'epic_notes',
            'epics'
          )
        ].freeze

        module ClassMethods
          def match(path)
            EE_ROUTES.find { |route| route.regexp.match(path) } || super
          end
        end

        def self.prepended(base)
          base.singleton_class.prepend ClassMethods
        end
      end
    end
  end
end
