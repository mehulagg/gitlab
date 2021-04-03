# frozen_string_literal: true

module NestedEpicsHelper
  def add_parents_to(epic:, count:)
    latest = nil

    count.times do
      latest = create(:epic, group: epic.group, parent: latest)
    end

    epic.update!(parent: latest)

    latest
  end

  def add_children_to(epic:, count:)
    latest = epic

    count.times do
      latest = create(:epic, group: epic.group, parent: latest)
    end

    latest
  end
end
