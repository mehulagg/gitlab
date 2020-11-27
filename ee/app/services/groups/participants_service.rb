# frozen_string_literal: true

module Groups
  class ParticipantsService < Groups::BaseService
    include Users::ParticipableService

    def execute(noteable)
      @noteable = noteable

      participants =
        noteable_owner.lazy +
        participants_in_noteable.lazy +
        all_members.lazy +
        groups.lazy +
        group_members.lazy

      participants.uniq
    end

    def all_members
      count = group_members.count
      [{ username: "all", name: "All Group Members", count: count }]
    end

    def group_members
      return [] unless noteable

      @group_members ||= sorted(noteable.group.direct_and_indirect_users)
    end
  end
end
