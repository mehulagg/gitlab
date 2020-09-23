# frozen_string_literal: true

module EE
  module API
    module Entities
      class LdapGroupLink < Grape::Entity
        expose :cn, :group_access, :provider
        expose :filter, if: ->(_, _) { License.feature_available?(:ldap_group_sync_filter) }
      end
    end
  end
end
