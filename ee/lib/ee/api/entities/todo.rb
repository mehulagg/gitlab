# frozen_string_literal: true

module EE
  module API
    module Entities
      module Todo
        extend ::Gitlab::Utils::Override
        extend ActiveSupport::Concern

        override :todo_target_class
        def todo_target_class(target_type)
          super
        rescue NameError
          # false as second argument prevents looking up in module hierarchy
          # see also https://gitlab.com/gitlab-org/gitlab-foss/issues/59719
          ::EE::API::Entities.const_get(target_type, false)
        end
      end
    end
  end
end
