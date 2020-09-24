# frozen_string_literal: true

module EE
  module Gitlab
    module Scim
      class Feature
        def self.scim_identities_enabled?(group)
          ::Feature.enabled?(:scim_identities, group, default_enabled: true)
        end
      end
    end
  end
end
