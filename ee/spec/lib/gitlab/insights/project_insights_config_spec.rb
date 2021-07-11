# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Insights::ProjectInsightsConfig do
  let_it_be(:project) { create(:project) }

  let(:chart1) { { title: 'chart 1', description: 'description 1' } }
  let(:chart2) { { title: 'chart 2', description: 'description 2' } }

  let(:config) do
    {
      item1: {
        title: 'item 1',
        charts: [
          chart1,
          chart2
        ]
      },
      item2: {
        title: 'item 3',
        charts: [
          {
            title: 'chart 3',
            description: 'description 3'
          }
        ]
      }
    }
  end

  subject { described_class.new(project: project, insights_config: config) }

  context 'filtering out invalid config entries' do
    let(:config_with_invalid_entry) { config.merge(".projectOnly": { projects: { only: [] } }) }

    subject { described_class.new(project: project, insights_config: config_with_invalid_entry) }

    it 'does not include invalid entry' do
      expect(subject.filtered_config).to eq(config)
    end

    it 'does not show notice text' do
      expect(subject.notice_text).to eq(nil)
    end
  end

  context 'when no projects.only filter present' do
    it 'does not change the config' do
      expect(subject.filtered_config).to eq(config)
    end

    it 'clones the original config' do
      expect(subject.filtered_config.object_id).not_to eq(config.object_id)
    end
  end

  context 'when not included in the projects.only filter' do
    context 'by project id' do
      before do
        chart = config[:item1][:charts].last
        chart[:projects] = { only: [-1] }
      end

      it 'filters out the chart' do
        expect(subject.filtered_config[:item1][:charts]).to eq([chart1])
      end

      it 'does not have a notice text' do
        expect(subject.notice_text).not_to eq(nil)
      end
    end

    context 'by project full path' do
      before do
        chart = config[:item1][:charts].last
        chart[:projects] = { only: ['some/full/path'] }
      end

      it 'filters out the chart' do
        expect(subject.filtered_config[:item1][:charts]).to eq([chart1])
      end
    end
  end

  context 'when included in projects.only filter' do
    context 'by project id' do
      before do
        chart = config[:item1][:charts].last
        chart[:projects] = { only: [project.id] }
      end

      it 'includes the chart' do
        expect(subject.filtered_config[:item1][:charts]).to eq([chart1, chart2])
      end

      it 'does not have notice text' do
        expect(subject.notice_text).to eq(nil)
      end
    end

    context 'by project full path' do
      before do
        chart = config[:item1][:charts].last
        chart[:projects] = { only: [project.full_path] }
      end

      it 'filters out the chart' do
        expect(subject.filtered_config[:item1][:charts]).to eq([chart1, chart2])
      end
    end
  end

  context 'when all charts are excluded' do
    before do
      config.each do |key, item|
        item[:charts].each do |chart|
          chart[:projects] = { only: [-1] }
        end
      end
    end

    it 'returns an empty hash' do
      expect(subject.filtered_config).to eq({})
    end
  end
end
