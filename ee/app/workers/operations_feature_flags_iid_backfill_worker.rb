# frozen_string_literal: true

class OperationsFeatureFlagsIidBackfillWorker
  include ApplicationWorker
  include CronjobQueue

  feature_category :operations_feature_flags

  # rubocop: disable CodeReuse/ActiveRecord
  def perform
    Operations::FeatureFlag.where(iid: nil).find_each do |flag|
      flag.ensure_project_iid!
      flag.save
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
