# frozen_string_literal: true

# Let variables required:
#
# - event
# - registry_class
#
RSpec.shared_examples 'event creates a registry' do
  it 'creates a registry with pending state' do
    expect { event.process }.to change(registry_class.with_state(:pending), :count).by(1)
  end
end

# Let variables required:
#
# - event
# - registry_class
#
RSpec.shared_examples 'event does not create a registry' do
  it 'does not create a registry' do
    expect { event.process }.not_to change(registry_class, :count)
  end
end

# Let variables required:
#
# - event
# - registry
#
RSpec.shared_examples 'event transitions a registry to pending' do
  it 'transitions the registry to pending' do
    event.process

    expect(registry.reload.pending?).to be_truthy
  end
end

# Let variables required:
#
# - event
# - registry
#
RSpec.shared_examples 'event does not transition a registry to pending' do
  it 'does not transition a registry to pending' do
    event.process

    expect(registry.reload.pending?).to be_falsey
  end
end

# Let variables required:
#
# - event
# - sync_worker_expected_arg
# - sync_worker_class
#
RSpec.shared_examples 'event schedules a sync worker' do
  it 'schedules a sync worker' do
    expect(sync_worker_class).to receive(:perform_async).with(sync_worker_expected_arg)

    event.process
  end
end

# Let variables required:
#
# - event
# - sync_worker_class
#
RSpec.shared_examples 'event does not schedule a sync worker' do
  it 'does not schedule a sync worker' do
    expect(sync_worker_class).not_to receive(:perform_async)

    event.process
  end
end

# Let variables required:
#
# - event
# - registry_factory
# - registry_factory_args
# - sync_worker_class
# - sync_worker_expected_arg
#
RSpec.shared_examples 'event should trigger a sync' do
  context 'when a registry does not yet exist' do
    it_behaves_like 'event creates a registry'
    it_behaves_like 'event schedules a sync worker'
    it_behaves_like 'logs event source info'
  end

  context 'when a registry exists' do
    let!(:registry) { create(registry_factory, *registry_factory_args) }

    it_behaves_like 'event transitions a registry to pending'
    it_behaves_like 'event schedules a sync worker'
    it_behaves_like 'logs event source info'
  end
end
