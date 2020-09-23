# frozen_string_literal: true

module EE
  module API
    module Entities
      module Analytics
        module GroupActivity
          class NewMembersCount < Grape::Entity
            expose :new_members_count
          end
        end
      end
    end
  end
end
