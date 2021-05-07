# frozen_string_literal: true

RSpec.shared_examples 'config settings return correct values' do
  it 'returns config' do
    expect(described_class.settings).to be_a(Elasticsearch::Model::Indexing::Settings)
  end

  it 'sets correct shard/replica settings' do
    allow(Elastic::IndexSetting).to receive(:[]).with(described_class.index_name).and_return(double(number_of_shards: 32, number_of_replicas: 2))

    settings = described_class.settings.to_hash
    expect(settings[:index][:number_of_shards].as_json).to eq(32)
    expect(settings[:index][:number_of_replicas].as_json).to eq(2)
  end
end
