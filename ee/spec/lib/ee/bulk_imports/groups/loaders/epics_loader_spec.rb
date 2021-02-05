# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Loaders::EpicsLoader do
  describe '#load' do
    it 'creates the epic' do
      stub_licensed_features(epics: true)

      user = create(:user)
      group = create(:group)
      group.add_owner(user)

      parent_epic = create(:epic, group: group)
      child_epic = create(:epic, group: group)
      label = create(:group_label, group: group)
      bulk_import = create(:bulk_import, user: user)
      entity = create(:bulk_import_entity, bulk_import: bulk_import, group: group)
      context = BulkImports::Pipeline::Context.new(entity)

      data = {
        'title' => 'epic',
        'state' => 'opened',
        'confidential' => false,
        'iid' => 99,
        'author_id' => user.id,
        'group_id' => group.id,
        'parent' => parent_epic,
        'children' => [child_epic],
        'labels' => [
          label
        ]
      }

      expect { subject.load(context, data) }.to change(::Epic, :count).by(1)

      epic = group.epics.last
      expect(epic.group).to eq(group)
      expect(epic.author).to eq(user)
      expect(epic.title).to eq('epic')
      expect(epic.state).to eq('opened')
      expect(epic.confidential).to eq(false)
      expect(epic.iid).to eq(99)
      expect(epic.parent).to eq(parent_epic)
      expect(epic.children).to contain_exactly(child_epic)
      expect(epic.labels).to contain_exactly(label)
    end
  end
end
