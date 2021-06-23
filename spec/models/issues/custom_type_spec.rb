# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issues::CustomType do
  describe 'modules' do
    it { is_expected.to include_module(CacheMarkdownField) }
    it { is_expected.to include_module(Sortable) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:issues).with_foreign_key('issue_custom_type_id') }
    it { is_expected.to belong_to(:group).with_foreign_key('namespace_id') }
  end

  describe '#destroy' do
    it 'does not cascade to issues' do
      issue = create(:issue)
      custom_type = create(:issue_custom_type, issues: [issue])

      expect { custom_type.destroy! }.not_to change(Issue, :count)
      expect(issue.reload.issue_custom_type_id).to be_nil
    end
  end

  describe 'validation' do
    describe 'name uniqueness' do
      subject { create(:issue_custom_type) }

      it { is_expected.to validate_uniqueness_of(:name).scoped_to([:namespace_id]) }
    end

    it 'validates name' do
      is_expected.not_to allow_value('G,ITLAB').for(:name)
      is_expected.not_to allow_value('').for(:name)
      is_expected.not_to allow_value('s' * 256).for(:name)

      is_expected.to allow_value('GITLAB').for(:name)
      is_expected.to allow_value('gitlab').for(:name)
      is_expected.to allow_value('G?ITLAB').for(:name)
      is_expected.to allow_value('G&ITLAB').for(:name)
      is_expected.to allow_value("customer's request").for(:name)
      is_expected.to allow_value('s' * 255).for(:name)
    end

    it { is_expected.not_to allow_value('s' * 256).for(:icon_name) }
  end

  describe '#name' do
    it 'sanitizes name' do
      custom_type = described_class.new(name: '<b>foo & bar?</b>')

      expect(custom_type.name).to eq('foo & bar?')
    end

    it 'strips name' do
      custom_type = described_class.new(name: '   label   ')
      custom_type.valid?

      expect(custom_type.name).to eq('label')
    end
  end

  describe '#description' do
    it 'sanitizes description' do
      custom_type = described_class.new(description: '<b>foo & bar?</b>')

      expect(custom_type.description).to eq('foo & bar?')
    end
  end
end
