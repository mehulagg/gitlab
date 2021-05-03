# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CycleAnalytics::ProjectValueStream, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }

    it 'validates uniqueness of name' do
      project = create(:project)
      create(:cycle_analytics_project_value_stream, name: 'test', project: project)

      value_stream = build(:cycle_analytics_project_value_stream, name: 'test', project: project)

      expect(value_stream).to be_invalid
      expect(value_stream.errors.messages).to eq(name: [I18n.t('errors.messages.taken')])
    end
  end

  it 'is not custom' do
    expect(described_class.new).not_to be_custom
  end
end
