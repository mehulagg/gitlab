# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Loaders
        class EpicsLoader
          def initialize(options = {})
            @options = options
          end

          def load(context, data)
            group = ::Group.find_by_id(context.entity.namespace_id)

            return unless Ability.allowed?(context.current_user, :create_epic, group)

            ::Epic.create!(data)
          end
        end
      end
    end
  end
end
