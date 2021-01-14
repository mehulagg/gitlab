# frozen_string_literal: true

class GroupOnlyTrialsExperiment < Gitlab::Experimentation::LegacyExperiment
  TRACKING_CATEGORY = 'Growth::Conversion::Experiment::GroupOnlyTrials'
  USE_BACKWARDS_COMPATIBLE_SUBJECT_INDEX = true
end
