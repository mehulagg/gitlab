# frozen_string_literal: true

class DefaultToIssuesBoardExperiment < Gitlab::Experimentation::LegacyExperiment
  TRACKING_CATEGORY = 'Growth::Conversion::Experiment::DefaultToIssuesBoard'
  USE_BACKWARDS_COMPATIBLE_SUBJECT_INDEX = true
end
