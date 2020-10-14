# frozen_string_literal: true

# Expects `job` and `perform` to be defined
RSpec.shared_examples 'reenqueuer' do
  before do
    allow(job).to receive(:sleep) # faster tests
  end

  it 'implements lease_timeout' do
    expect(job.lease_timeout).to be_a(ActiveSupport::Duration)
  end

  describe '#perform' do
    it 'tries to obtain a lease' do
      expect_to_obtain_exclusive_lease(job.lease_key)

      perform
    end
  end
end

# Expects `job` and `perform` to be defined
RSpec.shared_examples 'it is rate limited to 1 call per' do |minimum_duration|
  before do
    # Allow Timecop freeze and travel without the block form
    Timecop.safe_mode = false
    Timecop.freeze

    time_travel_during_perform(actual_duration)
  end

  after do
    Timecop.return
    Timecop.safe_mode = true
  end

  context 'when the work finishes in 0 seconds' do
    let(:actual_duration) { 0 }

    it 'sleeps exactly the minimum duration' do
      expect(job).to receive(:sleep).with(a_value_within(0.01).of(minimum_duration))

      perform
    end
  end

  context 'when the work finishes in 10% of minimum duration' do
    let(:actual_duration) { 0.1 * minimum_duration }

    it 'sleeps 90% of minimum duration' do
      expect(job).to receive(:sleep).with(a_value_within(0.01).of(0.9 * minimum_duration))

      perform
    end
  end

  context 'when the work finishes in 90% of minimum duration' do
    let(:actual_duration) { 0.9 * minimum_duration }

    it 'sleeps 10% of minimum duration' do
      expect(job).to receive(:sleep).with(a_value_within(0.01).of(0.1 * minimum_duration))

      perform
    end
  end

  context 'when the work finishes exactly at minimum duration' do
    let(:actual_duration) { minimum_duration }

    it 'does not sleep' do
      expect(job).not_to receive(:sleep)

      perform
    end
  end

  context 'when the work takes 10% longer than minimum duration' do
    let(:actual_duration) { 1.1 * minimum_duration }

    it 'does not sleep' do
      expect(job).not_to receive(:sleep)

      perform
    end
  end

  context 'when the work takes twice as long as minimum duration' do
    let(:actual_duration) { 2 * minimum_duration }

    it 'does not sleep' do
      expect(job).not_to receive(:sleep)

      perform
    end
  end

  def time_travel_during_perform(actual_duration)
    # Save the original implementation of ensure_minimum_duration
    original_ensure_minimum_duration = job.method(:ensure_minimum_duration)

    allow(job).to receive(:ensure_minimum_duration) do |minimum_duration, &block|
      original_ensure_minimum_duration.call(minimum_duration) do
        # Time travel inside the block inside ensure_minimum_duration
        Timecop.travel(actual_duration) if actual_duration && actual_duration > 0
      end
    end
  end
end
