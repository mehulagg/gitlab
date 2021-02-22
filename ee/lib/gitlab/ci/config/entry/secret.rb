# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a secret definition.
        #
        class Secret < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Attributable

          ALLOWED_KEYS = %i[vault file].freeze
          REQUIRED_KEYS = %i[vault].freeze

          attributes ALLOWED_KEYS

          entry :vault, Entry::Vault::Secret, description: 'Vault secrets engine configuration'
          entry :file, ::Gitlab::Config::Entry::Boolean, description: 'Should the created variable be of file type'

          validations do
            validates :config, allowed_keys: ALLOWED_KEYS, required_keys: REQUIRED_KEYS
          end
        end
      end
    end
  end
end
