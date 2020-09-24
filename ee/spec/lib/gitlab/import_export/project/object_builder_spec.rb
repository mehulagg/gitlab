# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ImportExport::Project::ObjectBuilder do
  let!(:group) { create(:group, :private) }
  let!(:subgroup) { create(:group, :private, parent: group) }
  let!(:project) do
    create(:project, :repository,
           :builds_disabled,
           :issues_disabled,
           name: 'project',
           path: 'project',
           group: subgroup)
  end

  context 'epics' do
    it 'finds the existing epic' do
      epic = create(:epic, title: 'epic', group: project.group)

      expect(described_class.build(Epic,
                                   'iid' => 1,
                                   'title' => 'epic',
                                   'group' => project.group,
                                   'author_id' => project.creator.id)).to eq(epic)
    end

    it 'finds the existing epic in root ancestor' do
      epic = create(:epic, title: 'epic', group: group)

      expect(described_class.build(Epic,
                                   'iid' => 1,
                                   'title' => 'epic',
                                   'group' => project.group,
                                   'author_id' => project.creator.id)).to eq(epic)
    end

    it 'creates a new epic' do
      epic = described_class.build(Epic,
                                   'iid' => 1,
                                   'title' => 'epic',
                                   'group' => project.group,
                                   'author_id' => project.creator.id)

      expect(epic.persisted?).to be true
    end
  end
end
