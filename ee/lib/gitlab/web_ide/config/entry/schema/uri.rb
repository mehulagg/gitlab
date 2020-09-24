# frozen_string_literal: true

module Gitlab
  module WebIde
    class Config
      module Entry
        class Schema
          ##
          # Entry that represents the URI of a schema
          #
          class Uri < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable

            validations do
              validates :config, presence: true, type: String
            end

            def self.default
              ''
            end
          end
        end
      end
    end
  end
end
