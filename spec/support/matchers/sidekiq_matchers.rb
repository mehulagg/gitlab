# frozen_string_literal: true

RSpec::Matchers.define :have_enqueued_sidekiq_mail do |klass, mailer|
  match do |actual|
    actual.call

    expect(Sidekiq::Queues['mailers'])
      .to include(a_hash_including('class' => 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper',
                                   'args' => [a_hash_including('arguments' => [klass.to_s, mailer.to_s, 'deliver_now', anything])]))
  end

  supports_block_expectations
end
