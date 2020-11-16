# frozen_string_literal: true

module EE
  module ProjectFeature
    extend ActiveSupport::Concern

    EE_FEATURES = %i(requirements).freeze

    prepended do
      set_available_features(EE_FEATURES)

      # Ensure changes to project visibility settings go to elasticsearch
      after_commit on: :update do
        project.maintain_elasticsearch_update if project.maintaining_elasticsearch?
      end

      default_value_for :requirements_access_level, value: Featurable::ENABLED, allows_nil: false
    end
  end
end
