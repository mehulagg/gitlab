# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespaceSetting, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to(:namespace) }
  end

  describe "Validation" do
    describe '#allow_mfa_for_group' do
      context 'group is top-level group' do
        let(:group) { create(:group) }

        it 'is valid when updated' do
          expect(group.namespace_settings.update(allow_mfa_for_subgroups: false)).to eq(true)
        end
      end

      context 'group is a subgroup' do
        let(:group) { create(:group, parent: create(:group)) }

        it 'is invalid when updated' do
          expect(group.namespace_settings.update(allow_mfa_for_subgroups: false)).to eq(false)
        end
      end
    end
  end
end
