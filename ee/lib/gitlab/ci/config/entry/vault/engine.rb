# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        module Vault
          ##
          # Entry that represents Vault secret engine.
          #
          class Engine < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable
            include ::Gitlab::Config::Entry::Attributable

            ALLOWED_KEYS = %i[name path].freeze

            attributes ALLOWED_KEYS

            validations do
              validates :config, type: Hash, allowed_keys: ALLOWED_KEYS, required_keys: ALLOWED_KEYS
              validates :name, presence: true, type: String
              validates :path, presence: true, type: String
            end
          end
        end
      end
    end
  end
end
