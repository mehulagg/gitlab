# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::Latest::CustomLanguageAnalyzers do
  describe '.custom_analyzers_fields' do
    before do
      allow(::Gitlab::CurrentSettings).to receive(:elasticsearch_analyzers_smartcn_enabled).and_return(smartcn_enabled)
      allow(::Gitlab::CurrentSettings).to receive(:elasticsearch_analyzers_kuromoji_enabled).and_return(kuromoji_enabled)
    end

    context 'all analyzers disabled' do
      let(:smartcn_enabled) { false }
      let(:kuromoji_enabled) { false }

      it 'returns config' do
        expect(described_class.custom_analyzers_fields(type: :text)).to eq({})
      end
    end

    context 'all analyzers enabled' do
      let(:smartcn_enabled) { true }
      let(:kuromoji_enabled) { true }

      it 'returns config' do
        expect(described_class.custom_analyzers_fields(type: :text)).to eq(smartcn: { analyzer: 'smartcn', type: :text }, kuromoji: { analyzer: 'kuromoji', type: :text })
      end
    end

    context 'smatcn enabled' do
      let(:smartcn_enabled) { true }
      let(:kuromoji_enabled) { false }

      it 'returns config' do
        expect(described_class.custom_analyzers_fields(type: :text)).to eq(smartcn: { analyzer: 'smartcn', type: :text })
      end
    end

    context 'kuromoji enabled' do
      let(:smartcn_enabled) { false }
      let(:kuromoji_enabled) { true }

      it 'returns config' do
        expect(described_class.custom_analyzers_fields(type: :text)).to eq(kuromoji: { analyzer: 'kuromoji', type: :text })
      end
    end
  end
end
