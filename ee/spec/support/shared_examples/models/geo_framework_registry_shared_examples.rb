# frozen_string_literal: true

RSpec.shared_examples 'a Geo framework registry' do
  let(:registry_class_factory) { described_class.underscore.tr('/', '_').to_sym }

  context 'finders' do
    let!(:failed_item1) { create(registry_class_factory, :failed) }
    let!(:failed_item2) { create(registry_class_factory, :failed) }
    let!(:unsynced_item1) { create(registry_class_factory) } # rubocop:disable Rails/SaveBang
    let!(:unsynced_item2) { create(registry_class_factory) } # rubocop:disable Rails/SaveBang

    describe '.find_registries_never_attempted_sync' do
      it 'returns unsynced items' do
        result = described_class.find_registries_never_attempted_sync(batch_size: 10)

        expect(result).to include(unsynced_item1, unsynced_item2)
      end

      it 'returns items that never have an attempt to sync except some specific item ID' do
        except_id = unsynced_item1.model_record_id

        result = described_class.find_registries_never_attempted_sync(batch_size: 10, except_ids: [except_id])

        expect(result).to include(unsynced_item2)
        expect(result).not_to include(unsynced_item1)
      end
    end

    describe '.find_registries_needs_sync_again' do
      it 'returns failed items' do
        result = described_class.find_registries_needs_sync_again(batch_size: 10)

        expect(result).to include(failed_item1, failed_item2)
      end

      it 'returns failed items except some specific item ID' do
        except_id = failed_item1.model_record_id

        result = described_class.find_registries_needs_sync_again(batch_size: 10, except_ids: [except_id])

        expect(result).to include(failed_item2)
        expect(result).not_to include(failed_item1)
      end
    end
  end
end
