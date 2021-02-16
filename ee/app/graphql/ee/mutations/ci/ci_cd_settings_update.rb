# frozen_string_literal: true

module EE
  module Mutations
    module Ci
      module CiCdSettingsUpdate
        extend ActiveSupport::Concern

        prepended do
          argument :merge_trains_manual_merge_disabled, GraphQL::BOOLEAN_TYPE,
                   required: false,
                   description: 'Indicates if manual merges(api, button, quick action) are disabled for this project when merge trains are enabled.'
        end
      end
    end
  end
end
