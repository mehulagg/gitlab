# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::IndexSetting do
  subject(:setting) { described_class.default }

  describe 'validations' do
    it { is_expected.to allow_value(10).for(:number_of_shards) }
    it { is_expected.not_to allow_value(nil).for(:number_of_shards) }
    it { is_expected.not_to allow_value(0).for(:number_of_shards) }
    it { is_expected.not_to allow_value(1.1).for(:number_of_shards) }
    it { is_expected.not_to allow_value(-1).for(:number_of_shards) }

    it { is_expected.to allow_value(10).for(:number_of_replicas) }
    it { is_expected.to allow_value(0).for(:number_of_replicas) }
    it { is_expected.not_to allow_value(nil).for(:number_of_replicas) }
    it { is_expected.not_to allow_value(1.1).for(:number_of_replicas) }
    it { is_expected.not_to allow_value(-1).for(:number_of_replicas) }

    it { is_expected.to allow_value('a').for(:alias_name) }
    it { is_expected.not_to allow_value('a' * 256).for(:alias_name) }
  end

  describe '.[]' do
    it 'returns existing record' do
      record = create(:elastic_index_setting)

      expect(described_class[record.alias_name]).to eq record
    end

    it 'creates a new record' do
      expect { described_class['new_alias'] }.to change { described_class.count }.by(1)
    end
  end

  describe '.default' do
    it 'returns index_setting record for the default index' do
      index_name = 'default_index_name'
      allow(Elastic::Latest::Config).to receive(:index_name).and_return(index_name)

      expect(described_class.default.alias_name).to eq(index_name)
    end
  end

  describe '.number_of_replicas' do
    it 'returns default number of replicas' do
      allow(described_class).to receive(:default).and_return(double(described_class, number_of_replicas: 2))

      expect(described_class.number_of_replicas).to eq(2)
    end
  end

  describe '.number_of_shards' do
    it 'returns default number of shards' do
      allow(described_class).to receive(:default).and_return(double(described_class, number_of_shards: 8))

      expect(described_class.number_of_shards).to eq(8)
    end
  end
end
