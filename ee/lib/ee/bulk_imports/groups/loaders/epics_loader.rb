# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Loaders
        class EpicsLoader
          AbilityNotAllowedError = Class.new(StandardError)

          def initialize(options = {})
            @options = options
          end

          def load(context, data)
            group = ::Group.find_by_id(context.entity.namespace_id)

            raise AbilityNotAllowedError unless Ability.allowed?(context.current_user, :create_epic, group)

            existing_epic = epic_exists?(data)

            if existing_epic
              # Do not create duplicate epic if it exists unless
              # new epic has parent information. Update existing
              # epic in this case.
              return if data_has_no_parent?(data)

              existing_epic.update!(parent: data['parent'])
            else
              ::Epic.create!(data)
            end
          end

          private

          def data_has_no_parent?(data)
            !data.key?('parent')
          end

          def epic_exists?(data)
            find_attributes = { group_id: data['group_id'], title: data['title'], description: data['description'], created_at: data['created_at'] }

            ::Epic.find_by(find_attributes) # rubocop: disable CodeReuse/ActiveRecord
          end
        end
      end
    end
  end
end
