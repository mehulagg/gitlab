# frozen_string_literal: true

RSpec.shared_examples 'tracking unique hll events' do |feature_flag|
  it 'tracks unique event' do
    expect(Gitlab::UsageDataCounters::HLLRedisCounter).to receive(:track_event).with(expected_type, target_id)

    subject
  end

  context 'when feature flag is disabled' do
    it 'does not track unique event' do
      stub_feature_flags(feature_flag => false)

      expect(Gitlab::UsageDataCounters::HLLRedisCounter).not_to receive(:track_event)

      subject
    end
  end
end
