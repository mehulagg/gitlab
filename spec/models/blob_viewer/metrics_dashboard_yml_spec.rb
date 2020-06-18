# frozen_string_literal: true

require 'spec_helper'

describe BlobViewer::MetricsDashboardYml do
  include FakeBlobHelpers
  include RepoHelpers

  let_it_be(:project) { create(:project, :repository) }
  let(:blob) { fake_blob(path: '.gitlab/dashboards/custom-dashboard.yml', data: data) }
  let(:sha) { sample_commit.id }

  subject(:viewer) { described_class.new(blob) }

  context 'when the definition is valid' do
    let(:data) { File.read(Rails.root.join('config/prometheus/common_metrics.yml')) }

    describe '#valid?' do
      it 'calls prepare! on the viewer' do
        allow(PerformanceMonitoring::PrometheusDashboard).to receive(:from_json)

        expect(viewer).to receive(:prepare!)

        viewer.valid?
      end

      it 'returns true', :aggregate_failures do
        yml = ::Gitlab::Config::Loader::Yaml.new(data).load_raw!

        expect_next_instance_of(::Gitlab::Config::Loader::Yaml, data) do |loader|
          expect(loader).to receive(:load_raw!).and_call_original
        end
        expect(PerformanceMonitoring::PrometheusDashboard)
          .to receive(:from_json)
          .with(yml)
          .and_call_original
        expect(viewer.valid?).to be_truthy
      end
    end

    describe '#errors' do
      it 'returns nil' do
        allow(PerformanceMonitoring::PrometheusDashboard).to receive(:from_json)

        expect(viewer.errors).to be nil
      end
    end
  end

  context 'when definition is invalid' do
    let(:error) { ActiveModel::ValidationError.new(PerformanceMonitoring::PrometheusDashboard.new.tap(&:validate)) }
    let(:data) do
      <<~YAML
        dashboard:
      YAML
    end

    describe '#valid?' do
      it 'returns false' do
        expect(PerformanceMonitoring::PrometheusDashboard)
          .to receive(:from_json).and_raise(error)

        expect(viewer.valid?).to be_falsey
      end
    end

    describe '#errors' do
      it 'returns validation errors' do
        allow(PerformanceMonitoring::PrometheusDashboard)
          .to receive(:from_json).and_raise(error)

        expect(viewer.errors).to be error.model.errors
      end
    end
  end

  context 'when YAML syntax is invalid' do
    let(:data) do
      <<~YAML
        dashboard: 'empty metrics'
         panel_groups:
        - group: 'Group Title'
      YAML
    end

    describe '#valid?' do
      it 'returns false' do
        expect(PerformanceMonitoring::PrometheusDashboard).not_to receive(:from_json)
        expect(viewer.valid?).to be_falsey
      end
    end

    describe '#errors' do
      it 'returns validation errors' do
        yaml_wrapped_errors = { 'YAML syntax': ["(<unknown>): did not find expected key while parsing a block mapping at line 1 column 1"] }

        expect(viewer.errors).to be_kind_of ActiveModel::Errors
        expect(viewer.errors.messages).to eql(yaml_wrapped_errors)
      end
    end
  end

  context 'when YAML loader raises error' do
    let(:data) do
      <<~YAML
        large yaml file
      YAML
    end

    before do
      allow(::Gitlab::Config::Loader::Yaml).to receive(:new)
        .and_raise(::Gitlab::Config::Loader::Yaml::DataTooLargeError, 'The parsed YAML is too big')
    end

    it 'is invalid' do
      expect(PerformanceMonitoring::PrometheusDashboard).not_to receive(:from_json)
      expect(viewer.valid?).to be(false)
    end

    it 'returns validation errors' do
      yaml_wrapped_errors = { 'YAML syntax': ["The parsed YAML is too big"] }

      expect(viewer.errors).to be_kind_of(ActiveModel::Errors)
      expect(viewer.errors.messages).to eq(yaml_wrapped_errors)
    end
  end
end
