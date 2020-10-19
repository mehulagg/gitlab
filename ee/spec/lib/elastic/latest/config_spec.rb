# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::Latest::Config do
  describe '.document_type' do
    it 'returns config' do
      expect(described_class.document_type).to eq('doc')
    end
  end

  describe '.settings' do
    it 'returns config' do
      expect(described_class.settings).to be_a(Elasticsearch::Model::Indexing::Settings)
    end
  end

  describe '.mappings' do
    it 'returns config' do
      expect(described_class.mapping).to be_a(Elasticsearch::Model::Indexing::Mappings)
    end

    it 'sets correct fields for title' do
      expect(Elastic::Latest::Config.mapping.to_hash[:doc][:properties][:title]).to eq({ type: :text, index_options: 'positions' })
    end
  end
end
