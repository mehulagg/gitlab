# frozen_string_literal: true

module EE
  module Types
    module Ci
      module CiCdSettingType
        extend ActiveSupport::Concern

        prepended do
          field :merge_trains_manual_merge_disabled, GraphQL::BOOLEAN_TYPE, null: false,
            description: 'Whether manual merges(api, button, quick action) ' \
              'are disabled for projects where merge trains are enabled.',
            method: :merge_trains_manual_merge_disabled?
        end
      end
    end
  end
end
