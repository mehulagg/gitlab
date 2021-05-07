# frozen_string_literal: true

module EE
  module Gitlab
    module SearchContext
      module Builder
        extend ::Gitlab::Utils::Override

        override :search_scope
        def search_scope
          if view_context.current_controller?(:epics)
            'epics'
          else
            super
          end
        end
      end
    end
  end
end
