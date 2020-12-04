# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a HTTP Get Probe.
        #
        class Probe
          class Exec < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable
            include ::Gitlab::Config::Entry::Attributable

            ALLOWED_KEYS = %i[command].freeze
            attributes ALLOWED_KEYS

            validations do
              validates :config, type: Hash
              validates :config, allowed_keys: ALLOWED_KEYS

              validates :command, array_of_strings: true
            end

            def value
              @config
            end
          end
        end
      end
    end
  end
end
