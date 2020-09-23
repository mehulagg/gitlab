# frozen_string_literal: true

module Groups
  class UpdateSharedRunnersService < Groups::BaseService
    def execute
      return error('Operation not allowed', 403) unless can?(current_user, :admin_group, group)

      validate_params

      update_shared_runners

      success

    rescue ActiveRecord::RecordInvalid, ArgumentError => error
      error(error.message)
    end

    private

    def validate_params
      unless Group::SHARED_RUNNERS_SETTINGS.include?(params[:shared_runners_setting])
        raise ArgumentError, "state must be one of: #{Group::SHARED_RUNNERS_SETTINGS.join(', ')}"
      end
    end

    def update_shared_runners
      group.update_shared_runners_setting!(params[:shared_runners_setting])
    end
  end
end
