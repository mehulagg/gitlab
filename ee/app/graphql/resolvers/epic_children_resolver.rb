# frozen_string_literal: true

module Resolvers
  class EpicChildrenResolver < EpicsResolver
    type Types::EpicType, null: true

    private

    def set_related_epic_param(args)
      args[:parent_id] = related_epic.id

      args
    end
  end
end
