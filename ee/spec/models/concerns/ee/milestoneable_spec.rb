# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Milestoneable do
  describe '#milestone_available?' do
    context 'for epics' do
      let(:epic) { build(:epic) }

      it 'returns true' do
        expect(epic.milestone_available?).to be(true)
      end
    end
  end

  describe '#supports_milestone?' do
    let(:group)   { create(:group) }
    let(:project) { create(:project, group: group) }

    context "for epics" do
      let(:epic) { build(:epic) }

      it 'returns false' do
        expect(epic.supports_milestone?).to be(false)
      end
    end
  end
end
