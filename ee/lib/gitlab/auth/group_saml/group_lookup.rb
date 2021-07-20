# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class GroupLookup
        def initialize(env)
          @env = env
        end

        def path
          path_from_callback_path || path_from_params
        end

        def group
          @group ||= Group.find_by_full_path(path)
        end

        def saml_provider
          group&.saml_provider
        end

        def group_saml_enabled?
          saml_provider&.enabled? && group.licensed_feature_available?(:group_saml)
        end

        def token_discoverable?
          group&.saml_discovery_token_matches?(params['token'])
        end

        private

        attr_reader :env

        def path_from_callback_path
          path = env['PATH_INFO']
          path_regex = Gitlab::PathRegex.saml_callback_regex

          path.match(path_regex).try(:[], :group)
        end

        def params
          @params ||= ActionDispatch::Request.new(env).params
        end

        def path_from_params
          params['group_path']
        end
      end
    end
  end
end
