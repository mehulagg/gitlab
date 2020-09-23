# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a secrets definition.
        #
        class Secrets < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          validations do
            validates :config, type: Hash
          end

          def compose!(deps = nil)
            super do
              @config.each do |name, config|
                factory = ::Gitlab::Config::Entry::Factory.new(Entry::Secret)
                  .value(config || {})
                  .with(key: name, parent: self, description: "#{name} secret definition") # rubocop:disable CodeReuse/ActiveRecord
                  .metadata(name: name)

                @entries[name] = factory.create!
              end

              @entries.each_value do |entry|
                entry.compose!(deps)
              end
            end
          end
        end
      end
    end
  end
end
