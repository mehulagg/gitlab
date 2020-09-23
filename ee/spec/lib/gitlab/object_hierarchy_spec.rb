# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ObjectHierarchy do
  let!(:parent) { create(:group) }
  let!(:child1) { create(:group, parent: parent) }
  let!(:child2) { create(:group, parent: child1) }

  describe '#root' do
    it 'includes only the roots' do
      relation = described_class.new(Group.where(id: child2)).roots

      expect(relation).to contain_exactly(parent)
    end

    it 'when quering parent it includes parent' do
      relation = described_class.new(Group.where(id: parent)).roots

      expect(relation).to contain_exactly(parent)
    end
  end
end
