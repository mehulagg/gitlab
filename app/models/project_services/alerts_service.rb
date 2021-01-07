# frozen_string_literal: true

# This service type is deprecated. All records must
# be removed before the class can be removed.
# https://gitlab.com/groups/gitlab-org/-/epics/5056
class AlertsService < Service
  def self.to_param
    'alerts'
  end

  def self.supported_events
    %w()
  end
end
