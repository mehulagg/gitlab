# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of probes.
        #
        class Probes < ::Gitlab::Config::Entry::ComposableArray
          include ::Gitlab::Config::Entry::Validatable

          validations do
            validates :config, presence: true
            validates :config, type: Array
          end

          def composable_class
            Entry::Probe
          end
        end
      end
    end
  end
end
