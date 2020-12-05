# frozen_string_literal: true

module IncidentManagement
  class OncallShiftsFinder
    def initialize(current_user, rotation, params = {})
      @current_user = current_user
      @rotation = rotation
      @params = params
      @current_time = Time.current
    end

    def execute
      return IncidentManagement::OncallShift.none unless params[:starts_at] && params[:ends_at]

      past_shifts + future_shifts
    end

    private

    attr_reader :current_user, :rotation, :params, :current_time
    delegate :participants, to: :rotation

    def past_shifts
      starts_at = params[:starts_at]
      ends_at = [params[:ends_at], current_time].min

      return IncidentManagement::OncallShift.none unless starts_at < ends_at

      rotation.shifts.where(starts_at: starts_at..ends_at)
    end

    def future_shifts
      starts_at = [params[:starts_at], current_time].max
      ends_at = params[:ends_at]

      return IncidentManagement::OncallShift.none unless starts_at < ends_at

      ::IncidentManagement::OncallShiftGenerator.new(
        rotation,
        starts_at: starts_at,
        ends_at: ends_at
      )
    end
  end
end
