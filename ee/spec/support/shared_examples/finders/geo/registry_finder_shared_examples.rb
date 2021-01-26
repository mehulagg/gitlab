# frozen_string_literal: true

RSpec.shared_examples 'a registry finder' do
  it 'responds to registry finder methods' do
    registry_finder_methods = %i{
      failed_count
      find_registries_never_attempted_sync
      find_registries_needs_sync_again
      registry_class
      registry_count
      synced_count
    }

    registry_finder_methods.each do |method|
      expect(subject).to respond_to(method)
    end
  end

  describe '#registry_count' do
    it 'counts registries' do
      expect(subject.registry_count).to eq 8
    end
  end

  describe '#synced_count' do
    it 'counts registries that has been synced' do
      expect(subject.synced_count).to eq 2
    end
  end

  describe '#failed_count' do
    it 'counts registries that sync has failed' do
      expect(subject.failed_count).to eq 4
    end
  end

  describe '#find_registries_never_attempted_sync' do
    it 'returns registries that have never been synced' do
      registries = subject.find_registries_never_attempted_sync(batch_size: 10)

      expect(registries).to match_ids(registry_3, registry_8)
    end

    it 'excludes except_ids' do
      registries = subject.find_registries_never_attempted_sync(batch_size: 10, except_ids: [replicable_3.id])

      expect(registries).to match_ids(registry_8)
    end
  end

  describe '#find_registries_needs_sync_again' do
    it 'returns registries for that have failed to sync' do
      registries = subject.find_registries_needs_sync_again(batch_size: 10)

      expect(registries).to match_ids(registry_1, registry_4, registry_6, registry_7)
    end

    it 'excludes except_ids' do
      registries = subject.find_registries_needs_sync_again(batch_size: 10, except_ids: [replicable_4.id, replicable_7.id])

      expect(registries).to match_ids(registry_1, registry_6)
    end
  end
end
