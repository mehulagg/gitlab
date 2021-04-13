# frozen_string_literal: true

module EE
  module Groups
    module VariablesController
      extend ::Gitlab::Utils::Override

      override :variable_params_attributes
      def variable_params_attributes
        if group.scoped_variables_available?
          super << :environment_scope
        else
          super
        end
      end
    end
  end
end
