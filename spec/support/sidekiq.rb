# frozen_string_literal: true

RSpec.configure do |config|
  def gitlab_sidekiq_inline(&block)
    # We need to cleanup the queues before running jobs in specs because the
    # middleware might have written to redis
    redis_queues_cleanup!
    Sidekiq::Testing.inline!(&block)
  ensure
    redis_queues_cleanup!
  end

  # As we'll review the examples with this tag, we should either:
  # - fix the example to not require Sidekiq inline mode (and remove this tag)
  # - explicitly keep the inline mode and change the tag for `:sidekiq_inline` instead
  config.around(:example, :sidekiq_might_not_need_inline) do |example|
    gitlab_sidekiq_inline { example.run }
  end

  config.around(:example, :sidekiq_inline) do |example|
    gitlab_sidekiq_inline { example.run }
  end

  # Some specs need to run mailers through Sidekiq explicitly, rather
  # than the ActiveJob test adapter. There is a Rails bug that means we
  # have to do some extra steps to make this happen:
  # https://github.com/rails/rails/issues/37270#issuecomment-553927324
  config.around(:example, :sidekiq_mailers) do |example|
    original_queue_adapter = ActiveJob::Base.queue_adapter
    descendants = ActiveJob::Base.descendants + [ActiveJob::Base]

    ActiveJob::Base.queue_adapter = :sidekiq
    descendants.each(&:disable_test_adapter)

    example.run

    descendants.each { |a| a.enable_test_adapter(ActiveJob::QueueAdapters::TestAdapter.new) }
    ActiveJob::Base.queue_adapter = original_queue_adapter
  end
end
