# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        module Vault
          ##
          # Entry that represents Vault secret.
          #
          class Secret < ::Gitlab::Config::Entry::Simplifiable
            strategy :StringStrategy, if: -> (config) { config.is_a?(String) }
            strategy :HashStrategy, if: -> (config) { config.is_a?(Hash) }

            class UnknownStrategy < ::Gitlab::Config::Entry::Node
              def errors
                ["#{location} should be a hash or a string"]
              end
            end

            class StringStrategy < ::Gitlab::Config::Entry::Node
              include ::Gitlab::Config::Entry::Validatable

              validations do
                validates :config, presence: true
                validates :config, type: String
              end

              def value
                {
                  engine: {
                    name: 'kv-v2', path: secret[:engine_path]
                  },
                  path: secret[:secret_path],
                  field: secret[:secret_field]
                }
              end

              private

              def secret
                @secret ||= begin
                  secret, engine_path = secret_and_engine
                  secret_path, _, secret_field = secret.rpartition('/')

                  {
                    engine_path: engine_path,
                    secret_path: secret_path,
                    secret_field: secret_field
                  }
                end
              end

              def secret_and_engine
                secret, _, engine = config.rpartition('@')

                if secret == ""
                  secret = config
                  engine = 'kv-v2'
                end

                [secret, engine]
              end
            end

            class HashStrategy < ::Gitlab::Config::Entry::Node
              include ::Gitlab::Config::Entry::Configurable
              include ::Gitlab::Config::Entry::Attributable

              ALLOWED_KEYS = %i[engine path field].freeze

              attributes ALLOWED_KEYS

              entry :engine, Entry::Vault::Engine, description: 'Vault secrets engine configuration'

              validations do
                validates :config, allowed_keys: ALLOWED_KEYS
                validates :path, presence: true, type: String
                validates :field, presence: true, type: String
                validates :engine, presence: true, type: Hash
              end

              def value
                {
                  engine: engine_value,
                  path: path,
                  field: field
                }
              end
            end
          end
        end
      end
    end
  end
end
