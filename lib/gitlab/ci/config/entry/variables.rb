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

          validations do
            validates :config, variables: true, unless: :prefilled_variables_enabled?
            validates :config, variables: { hash_values: true }, if: :prefilled_variables_enabled?
          end

          def value
            if prefilled_variables_enabled?
              new_value
            else
              legacy_value
            end
          end

          def self.default(**)
            {}
          end

          def prefilled_variables_enabled?
            ::Feature.enabled?(:ci_prefilled_variables)
          end

          private

          def new_value
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

          def legacy_value
            Hash[@config.map { |key, value| [key.to_s, value.to_s] }]
          end
        end
      end
    end
  end
end
