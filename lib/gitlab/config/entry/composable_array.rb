# frozen_string_literal: true

module Gitlab
  module Config
    module Entry
      ##
      # Entry that represents a composable hash definition
      # Where each hash key can be any value written by the user
      #
      class ComposableArray < ::Gitlab::Config::Entry::Node
        include ::Gitlab::Config::Entry::Validatable

        validations do
          validates :config, type: Array
        end

        def compose!(deps = nil)
          super(deps) do
            [@config].flatten.each_with_index do |value, index|
              composable_class = opt(:composable_class)
              raise ArgumentError, 'Missing Composable class' unless composable_class

              composable_class_name = composable_class.name.split('::').last

              @entries[index] = ::Gitlab::Config::Entry::Factory.new(composable_class)
                .value(value)
                .with(key: composable_class_name, parent: self, description: "#{composable_class_name} definition") # rubocop:disable CodeReuse/ActiveRecord
                .create!
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
