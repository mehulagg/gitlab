# frozen_string_literal: true

class CustomizeHomepageExperiment < Gitlab::Experimentation::LegacyExperiment
  TRACKING_CATEGORY = 'Growth::Expansion::Experiment::CustomizeHomepage'
  USE_BACKWARDS_COMPATIBLE_SUBJECT_INDEX = true
end
