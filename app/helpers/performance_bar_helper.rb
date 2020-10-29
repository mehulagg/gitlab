# frozen_string_literal: true

module PerformanceBarHelper
  def performance_bar_enabled?
    false
    # Gitlab::PerformanceBar.enabled_for_request?
  end
end
