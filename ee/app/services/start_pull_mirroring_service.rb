# frozen_string_literal: true

class StartPullMirroringService < BaseService
  INTERVAL = 5.minutes

  def execute
    import_state = project.import_state

    return error('Mirroring for the project is on pause', 403) if params[:pause_on_hard_failure] && import_state.hard_failed?

    if update_now?(import_state)
      import_state.force_import_job!
    else
      import_state.reset_retry_count if import_state.hard_failed?
      import_state.update(next_execution_timestamp: INTERVAL.since(import_state.last_update_at))
    end

    success
  end

  private

  def update_now?(import_state)
    import_state.last_successful_update_at.nil? ||
      import_state.last_update_at.nil? ||
      import_state.last_update_at < INTERVAL.ago
  end
end
