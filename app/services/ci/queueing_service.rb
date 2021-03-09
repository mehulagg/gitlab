# frozen_string_literal: true

puts "Loaded"
module Ci
  class QueueingService
    TYPES = [Ci::Queueing::LegacyDatabaseService].freeze

    def self.fabricate!(runner)
      type = self.find(runner)
      type.new(runner)
    end

    def self.find(runner)
      TYPES.find do |type|
        type.matching?(runner)
      end
    end
  end
end
