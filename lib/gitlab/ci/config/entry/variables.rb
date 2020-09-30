# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents environment variables.
        #
        class Variables < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          ALLOWED_VALUE_DATA = %i[value description].freeze

          validations do
            validates :config, variables: { allowed_value_data: ALLOWED_VALUE_DATA }
          end

          def value
            Hash[
              @config.map do |key, value|
                if value.is_a?(Hash)
                  [key.to_s, value[:value].to_s]
                else
                  [key.to_s, value.to_s]
                end
              end
            ]
          end

          def self.default(**)
            {}
          end

          def value_with_data
            Hash[
              @config.map do |key, value|
                if value.is_a?(Hash)
                  [key.to_s, { 'value' => value[:value].to_s, 'description' => value[:description].to_s }]
                else
                  [key.to_s, { 'value' => value.to_s, 'description' => '' }]
                end
              end
            ]
          end
        end
      end
    end
  end
end
