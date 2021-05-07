# frozen_string_literal: true

module EE
  module API
    module Helpers
      module VariablesHelpers
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        prepended do
          params :optional_group_variable_params_ee do
            optional :environment_scope, type: String, desc: 'The environment scope of the variable'
          end
        end

        override :filter_variable_parameters
        def filter_variable_parameters(owner, params)
          if owner.is_a?(::Group) && !owner.scoped_variables_available?
            params.delete(:environment_scope)
          end

          params
        end
      end
    end
  end
end
