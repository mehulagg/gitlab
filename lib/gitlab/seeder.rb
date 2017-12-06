# :nocov:
module DeliverNever
  def deliver_later
    self
  end
end

module Gitlab
  class Seeder
    def self.quiet
      mute_mailer unless Rails.env.test?

      SeedFu.quiet = true

      yield

      SeedFu.quiet = false
      puts "\nOK".color(:green)
    end

    def self.mute_mailer
      ActionMailer::MessageDelivery.prepend(DeliverNever)
    end
  end
end
# :nocov:
