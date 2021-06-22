# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents additional DAST configuration.
        #
        class DastConfiguration < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Attributable

          ALLOWED_KEYS = %i[site_profile scanner_profile].freeze

          attributes ALLOWED_KEYS

          validations do
            validates :config, allowed_keys: ALLOWED_KEYS
            validates :site_profile, type: String, allow_nil: true
            validates :scanner_profile, type: String, allow_nil: true
          end
        end
      end
    end
  end
end
