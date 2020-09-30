# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        ##
        # Entry that represents an array of JSON/YAML schemas
        #
        class Schemas < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Validatable

          entry :schema, Entry::Schema, description: 'A JSON/YAML schema definition'

          validations do
            validates :config, type: Array
          end

          def skip_config_hash_validation?
            true
          end
        end
      end
    end
  end
end
