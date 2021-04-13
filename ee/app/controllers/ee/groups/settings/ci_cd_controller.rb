# frozen_string_literal: true

module EE
  module Groups
    module Settings
      module CiCdController
        extend ::Gitlab::Utils::Override

        override :push_licensed_features
        def push_licensed_features
          push_licensed_feature(:group_scoped_ci_variables, group)
        end
      end
    end
  end
end
