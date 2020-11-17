# frozen_string_literal: true

module API
  module Validations
    module Validators
      class IntegerOrCustomValue < Grape::Validations::Base
        def initialize(attrs, options, required, scope, **opts)
          @custom_values = extract_custom_values(options)
          super
        end

        def validate_param!(attr_name, params)
          value = params[attr_name]
          custom_ids = @custom_values.is_a?(Proc) ? @custom_values.call : @custom_values

          return if custom_ids.nil?
          return if value.is_a?(Integer) || custom_ids.map(&:downcase).include?(value.to_s.downcase)

          raise Grape::Exceptions::Validation,
                params: [@scope.full_name(attr_name)],
                message: "should be an integer, or one of #{custom_ids.join(', ')}, however got #{value}"
        end

        private

        def extract_custom_values(options)
          options.is_a?(Hash) ? options[:values] : options
        end
      end
    end
  end
end
