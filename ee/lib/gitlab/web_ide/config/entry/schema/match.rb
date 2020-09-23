# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        class Schema
          ##
          # Entry that represents a list of glob expressions to match against the target file.
          #
          class Match < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable

            validations do
              validates :config, array_of_strings: true, presence: true
            end

            def self.default
              []
            end
          end
        end
      end
    end
  end
end
