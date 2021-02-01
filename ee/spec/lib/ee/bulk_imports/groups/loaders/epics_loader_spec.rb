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
        'title' => 'epic1',
        'state' => 'opened',
        'confidential' => false
      }
    end

    subject { described_class.new }

    it 'creates the epic' do
      expect { subject.load(context, data) }.to change(::Epic, :count).by(1)

      expect(group.epics.count).to eq(1)
    end
  end
end
