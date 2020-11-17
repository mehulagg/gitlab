# frozen_string_literal: true

module EE
  module API
    module Helpers
      module WikisHelpers
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        class_methods do
          def wiki_resource_kinds
            [:groups, *super]
          end
        end

        override :find_container
        def find_container(kind)
          return user_group if kind == :groups

          super
        end
      end
    end
  end
end
