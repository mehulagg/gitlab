# frozen_string_literal: true

module EE
  module Gitlab
    module Uploads
      module MigrationHelper
        extend ActiveSupport::Concern

        EE_CATEGORIES = [%w(IssuableMetricImageUploader IssuableMetricImage :file)].freeze

        class_methods do
          extend ::Gitlab::Utils::Override

          override :categories
          def categories
            super + EE_CATEGORIES
          end
        end
      end
    end
  end
end
