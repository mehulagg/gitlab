# frozen_string_literal: true

class CiNotificationDotExperiment < Gitlab::Experimentation::LegacyExperiment
  TRACKING_CATEGORY = 'Growth::Expansion::Experiment::CiNotificationDot'
  USE_BACKWARDS_COMPATIBLE_SUBJECT_INDEX = true
end
