# frozen_string_literal: true

module EE
  module Gitlab
    module WebIde
      module Config
        module Entry
          module Global
            extend ActiveSupport::Concern

            class_methods do
              def allowed_keys
                %i[terminal schemas].freeze
              end
            end

            prepended do
              entry :schemas, ::Gitlab::WebIde::Config::Entry::Schemas,
                description: 'Configuration of JSON/YAML schemas.'
            end
          end
        end
      end
    end
  end
end
