# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        class Caches < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          validations do
            validates :config, presence: true
            validates :config, type: Array
          end

          def self.aspects
            super.append -> do
              @config = Array.wrap(@config)

              @config.each_with_index do |config, i|
                @entries[i] = ::Gitlab::Config::Entry::Factory.new(Entry::Cache)
                                .value(config || {})
                                .create!
              end
            end
          end
        end
      end
    end
  end
end
