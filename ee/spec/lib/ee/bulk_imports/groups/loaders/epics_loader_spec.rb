# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Loaders::EpicsLoader do
  describe '#load' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }
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
            'title' => 'epic1',
            'state' => 'opened',
            'confidential' => false
          },
          {
            'title' => 'epic2',
            'state' => 'closed',
            'confidential' => true
          }
        ]
      }
    end

    subject { described_class.new }

    it 'creates the epics and update the entity tracker' do
      expect { subject.load(context, data) }.to change(::Epic, :count).by(2)

      tracker = entity.trackers.last

      expect(group.epics.count).to eq(2)
      expect(tracker.has_next_page).to eq(true)
      expect(tracker.next_page).to eq('endCursorValue')
    end
  end
end
