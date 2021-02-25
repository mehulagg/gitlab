module Deployments
  class DailyMetrics < ApplicationRecord
    self.table_name = 'deployments_daily_metrics'

    belongs_to :project
    belongs_to :environment
  end
end
