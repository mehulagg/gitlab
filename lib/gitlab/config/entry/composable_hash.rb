# frozen_string_literal: true

module Gitlab
  module Config
    module Entry
      ##
      # Entry that represents a composable hash definition
      # Where each hash key can be any value written by the user
      #
      class ComposableHash < ::Gitlab::Config::Entry::Node
        include ::Gitlab::Config::Entry::Validatable

        validations do
          validates :config, type: Hash
        end

        def compose!(deps = nil)
          super do
            @config.each do |name, config|
              composable_class = opt(:composable_class)
              raise ArgumentError, 'Missing Composable class' unless composable_class
              composable_name = composable_class.name.to_s.downcase

              factory = ::Gitlab::Config::Entry::Factory.new(composable_class)
                .value(config || {})
                .with(key: name, parent: self, description: "#{name} #{composable_name} definition") # rubocop:disable CodeReuse/ActiveRecord
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
