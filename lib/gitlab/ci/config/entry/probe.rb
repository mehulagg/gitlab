# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of a service Probe.
        #
        class Probe < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Attributable
          include ::Gitlab::Config::Entry::Configurable

          ALLOWED_PROBES = %i[tcp http_get exec]
          ALLOWED_KEYS = ALLOWED_PROBES + %i[retries initial_delay period timeout].freeze

          validations do
            validates :config, presence: true
            validates :config, type: Hash
            validates :config, allowed_keys: ALLOWED_KEYS
            validates :config, absence: { message: 'requires tcp, http_get or exec probe' }, unless: :has_probe?

            validates :retries, type: Integer, allow_nil: true
            validates :initial_delay, type: Integer, allow_nil: true
            validates :period, type: Integer, allow_nil: true
            validates :timeout, type: Integer, allow_nil: true
          end

          attributes ALLOWED_KEYS

          entry :tcp, Entry::Probe::Tcp
          entry :http_get, Entry::Probe::HttpGet
          entry :exec, Entry::Probe::Exec

          def value
            @config
          end

          def has_probe?
            return false unless hash?

            ALLOWED_PROBES.any? {|k| @config.key?(k)}
          end
        end
		  end
	  end
  end
end
