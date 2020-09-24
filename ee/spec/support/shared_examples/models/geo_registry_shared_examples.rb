# frozen_string_literal: true

RSpec.shared_examples 'a Geo registry' do
  describe '#start_sync!' do
    it 'updates last_synced_at' do
      expect { registry.start_sync! }
        .to change { registry.reload.last_synced_at }
    end
  end

  describe '#fail_sync!' do
    it 'fails registry record' do
      error = StandardError.new('Something is wrong')

      registry.fail_sync!('Failed', error)

      expect(registry).to have_attributes(
        retry_count: 1,
        retry_at: be_present,
        last_sync_failure: 'Failed: Something is wrong',
        state: 'failed'
      )
    end
  end

  describe '#repository_updated!' do
    it 'resets the state of the sync' do
      registry.state = :synced

      registry.repository_updated!

      expect(registry.pending?).to be true
    end
  end
end
