# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        ##
        # Entry that represents a JSON/YAML schema.
        #
        class Schema < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Attributable

          ALLOWED_KEYS = %i[uri match].freeze

          validations do
            validates :config, allowed_keys: ALLOWED_KEYS
          end

          entry :uri, Entry::Schema::Uri,
            description: 'The URI of the schema.'

          entry :match, Entry::Schema::Match,
            description: 'A list of glob expressions to match against the target file.'

          def value
            to_hash.compact
          end

          private

          def to_hash
            { uri: uri_value,
              match: match_value || [] }
          end
        end
      end
    end
  end
end
