# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents mirroring the status of another project pipeline.
        #
        # TODO: move to EE
        class Status < ::Gitlab::Config::Entry::Simplifiable
          # This can be extended to complex strategy that allows to specify `ref` etc...
          strategy :SimpleStatus, if: -> (config) { config.is_a?(String) }

          class SimpleStatus < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable

            validations { validates :config, presence: true }

            def value
              { project: @config }
            end
          end

          class UnknownStrategy < ::Gitlab::Config::Entry::Node
            def errors
              ["#{location} has to be a string"]
            end
          end
        end
      end
    end
  end
end
