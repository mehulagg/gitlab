# frozen_string_literal: true

# Include these shared examples in BlobReplicatorStrategy,
# RepositoryReplicatorStrategy, etc.
#
# Required let variables:
#
#   - `replicator` should be an instance of the Replicator class being tested, e.g. PackageFileReplicator
#   - `model_record` should be a valid instance of the model class. It may be unpersisted.
#   - `primary` should be the primary GeoNode
#   - `secondary` should be a secondary GeoNode
#
RSpec.shared_examples 'a replicator' do
  include EE::GeoHelpers

  context 'Geo node status' do
    context 'on a secondary node' do
      let_it_be(:registry_factory) { registry_factory_name(described_class.registry_class) }

      before do
        create(registry_factory, :synced)
        create(registry_factory) # rubocop: disable Rails/SaveBang
        create(registry_factory, :failed)
      end

      describe '.synced_count' do
        it 'returns the number of synced items on secondary' do
          expect(described_class.synced_count).to eq(1)
        end
      end

      describe '.failed_count' do
        it 'returns the number of failed items on secondary' do
          expect(described_class.failed_count).to eq(1)
        end
      end
    end
  end
end
