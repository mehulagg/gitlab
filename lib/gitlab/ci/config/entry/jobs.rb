# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a set of jobs.
        #
        class Jobs < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Validatable

          validations do
            validates :config, type: Hash

            validate do
              each_unmatched_job do |name|
                errors.add(name, 'config should implement a script: or a trigger: keyword')
              end

              unless has_visible_job?
                errors.add(:config, 'should contain at least one visible job')
              end
            end

            def each_unmatched_job
              config.each do |name, value|
                yield(name) unless Jobs.find_type(name, value)
              end
            end

            def has_visible_job?
              config.any? do |name, value|
                Jobs.find_type(name, value)&.visible?
              end
            end
          end

          TYPES = [Entry::Hidden, Entry::Job, Entry::Bridge].freeze

          private_constant :TYPES

          entries TYPES, description: "%s job definition"

          def self.all_types
            TYPES
          end

          def self.find_type(name, config)
            self.all_types.find do |type|
              type.matching?(name, config)
            end
          end
        end
      end
    end
  end
end
