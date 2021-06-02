# frozen_string_literal: true

RSpec::Matchers.define :have_enqueued_sidekiq_mail do |klass, mailer, *args|
  match do |actual|
    actual.call if actual.is_a?(Proc)

    expect(Sidekiq::Queues['mailers']).to have_mailer_job(klass, mailer, *args)
  end

  supports_block_expectations
end

RSpec::Matchers.define :have_mailer_job do |klass, mailer, *args|
  match do |actual|
    args = if args.any?
             ActiveJob::Arguments.serialize(args)
           else
             [anything]
           end

    expected_arguments = [klass.to_s, mailer.to_s, 'deliver_now', a_hash_including('args' => args)]

    expect(actual)
      .to include(a_hash_including('class' => 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper',
                                   'args' => [a_hash_including('arguments' => expected_arguments)]))
  end
end
