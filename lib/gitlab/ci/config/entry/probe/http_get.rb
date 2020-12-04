# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a HTTP Get Probe.
        #
        class Probe
          class HttpGet < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable
            include ::Gitlab::Config::Entry::Attributable

            ALLOWED_KEYS = %i[path port headers scheme].freeze
            attributes ALLOWED_KEYS

            validations do
              validates :config, type: Hash
              validates :config, allowed_keys: ALLOWED_KEYS

              validates :port, type: Integer, allow_nil: true
              validates :scheme, type: String, inclusion: { in: %w[http https], message: 'should be http or https' }, allow_blank: true
              validates :path, type: String, presence: false, allow_blank: true
              validates :headers, array_of_strings: {
                with: /\A[\w-]+:.*\z/,
                message: "must be in the format of 'Header-Name: Value'"
              }, allow_blank: true
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
