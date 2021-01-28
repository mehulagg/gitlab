# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::PrometheusMetrics::ObserveHistogramsService do
  let_it_be(:project) { create(:project) }
  let(:params) { {} }

  subject(:execute) { described_class.new(project, params).execute }

  context 'with empty data' do
    it 'does not raise errors' do
      expect(subject.status).to eq(201)
    end
  end

  context 'observes metrics successfully' do
    let(:params) do
      { histograms: [{ name: 'draw_links', duration: '4' }] }
    end

    it 'increments the metrics' do
      execute

      histogram_data = described_class
        .available_histograms['draw_links']
        .call.get({ project: project.full_path })

      expect(histogram_data).to match(a_hash_including({ 2.5 => 0.0, 5 => 1.0, 10 => 1.0 }))
    end

    it 'returns an empty body and status code' do
      expect(subject.status).to eq(201)
      expect(subject.body).to eq({})
    end
  end

  context 'with unknown histograms' do
    let(:params) do
      { histograms: [{ name: 'chunky_bacon', duration: '4' }] }
    end

    it 'raises ActiveRecord::RecordNotFound error' do
      expect { subject }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
