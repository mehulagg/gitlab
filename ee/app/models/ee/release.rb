# frozen_string_literal: true

module EE
  module Release
    extend ActiveSupport::Concern

    prepended do
      include UsageStatistics
      
      scope :project_releases, -> { where.not(project_id: nil) }
      scope :milestone_releases, -> { where(project_id: nil) }
    end
  end
end
