# frozen_string_literal: true

module EE
  module Gitlab
    module Auth
      module Ldap
        module Config
          extend ActiveSupport::Concern

          class_methods do
            extend ::Gitlab::Utils::Override

            def group_sync_enabled?
              enabled? && ::License.feature_available?(:ldap_group_sync)
            end

            override :_available_servers
            def _available_servers
              ::License.feature_available?(:multiple_ldap_servers) ? servers : super
            rescue ActiveRecord::NoDatabaseError
              # Rake is probably trying to initialize the DB
              []
            end
          end
        end
      end
    end
  end
end
