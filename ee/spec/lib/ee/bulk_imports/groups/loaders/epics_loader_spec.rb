# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Loaders::EpicsLoader do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:label) { create(:group_label, group: group) }
  let(:entity) { create(:bulk_import_entity, group: group) }

  let(:context) do
    BulkImports::Pipeline::Context.new(
      entity: entity,
      current_user: user
    )
  end

  let(:data) do
    {
      'page_info' => {
        'end_cursor' => 'endCursorValue',
        'has_next_page' => true
      },
      'nodes' => [
        {
          'title' => 'epic',
          'state' => 'opened',
          'confidential' => false,
          'labels' => [
            label.title
          ]
        }
      ]
    }.with_indifferent_access # Epics::CreateService access the data via symbols
  end

  before do
    # group.add_owner(user)
    # FIXME:
    expect(Ability)
      .to receive(:allowed?)
      .at_least(1)
      .and_return(true)
  end

  describe '#load' do
    it 'creates the epics and update the entity tracker' do
      expect { subject.load(context, data) }.to change(::Epic, :count).by(1)

      epic = group.epics.last
      expect(epic.title).to eq('epic')
      expect(epic.state).to eq('opened')
      expect(epic.confidential).to eq(false)
      expect(epic.labels).to contain_exactly(label)

      tracker = entity.trackers.last
      expect(tracker.has_next_page).to eq(true)
      expect(tracker.next_page).to eq('endCursorValue')
    end
  end
end
