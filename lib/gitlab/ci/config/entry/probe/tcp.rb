# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a TCP Probe.
        #
        class Probe
          class Tcp < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable
            include ::Gitlab::Config::Entry::Attributable

            ALLOWED_KEYS = %i[port].freeze
            attributes ALLOWED_KEYS

            validations do
              validates :config, type: Hash
              validates :config, allowed_keys: ALLOWED_KEYS

              validates :port, type: Integer, presence: true
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
