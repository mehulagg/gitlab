# frozen_string_literal: true

RSpec.shared_examples 'a file registry finder' do
  include_examples 'a registry finder'

  it 'responds to file registry finder methods' do
    file_registry_finder_methods = %i{
      synced_missing_on_primary_count
      find_retryable_synced_missing_on_primary_registries
    }

    file_registry_finder_methods.each do |method|
      expect(subject).to respond_to(method)
    end
  end

  describe '#synced_missing_on_primary_count' do
    it 'counts registries that have been synced and are missing on the primary, excluding not synced ones' do
      expect(subject.synced_missing_on_primary_count).to eq 2
    end
  end

  describe '#find_retryable_synced_missing_on_primary_registries' do
    it 'returns registries that have been synced and are missing on the primary' do
      registries = subject.find_retryable_synced_missing_on_primary_registries(batch_size: 10)

      expect(registries).to match_ids(registry_2, registry_5)
    end

    it 'excludes except_ids' do
      registries = subject.find_retryable_synced_missing_on_primary_registries(batch_size: 10, except_ids: [replicable_5.id])

      expect(registries).to match_ids(registry_2)
    end
  end
end
