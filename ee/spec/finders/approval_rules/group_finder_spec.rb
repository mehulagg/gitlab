# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApprovalRules::GroupFinder do
  let(:rule) { create(:approval_project_rule) }
  let(:user) { create(:user) }

  let(:public_group) { create(:group, name: 'public_group') }
  let(:private_inaccessible_group) { create(:group, :private, name: 'private_inaccessible_group') }
  let(:private_accessible_group) { create(:group, :private, name: 'private_accessible_group') }

  subject { described_class.new(rule, user) }

  before do
    private_accessible_group.add_owner(user)
  end

  context 'when with inaccessible groups' do
    before do
      rule.groups = [public_group, private_inaccessible_group, private_accessible_group]
    end

    it 'returns groups' do
      expect(subject.visible_groups).to contain_exactly(public_group, private_accessible_group)
      expect(subject.hidden_groups).to contain_exactly(private_inaccessible_group)
      expect(subject.contains_hidden_groups?).to eq(true)
    end
  end

  context 'when without inaccessible groups' do
    before do
      rule.groups = [public_group, private_accessible_group]
    end

    it 'returns groups' do
      expect(subject.visible_groups).to contain_exactly(public_group, private_accessible_group)
      expect(subject.hidden_groups).to be_empty
      expect(subject.contains_hidden_groups?).to eq(false)
    end
  end
end
