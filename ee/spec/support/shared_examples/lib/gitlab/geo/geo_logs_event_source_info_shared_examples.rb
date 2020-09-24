# frozen_string_literal: true

RSpec.shared_examples 'logs event source info' do
  it 'logs `job_id` and `event_id' do
    expect_any_instance_of(Gitlab::Geo::LogCursor::Logger).to receive(:info)
      .with(
        anything,
        hash_including(:job_id, :event_id))
      .at_least(:once)
      .and_call_original

    subject.process
  end
end
