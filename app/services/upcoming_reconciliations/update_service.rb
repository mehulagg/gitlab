# frozen_string_literal: true

module UpcomingReconciliations
  class UpdateService
    def initialize(upcoming_reconciliations)
      @upcoming_reconciliations = upcoming_reconciliations
    end

    def execute
      if @preferences.update(@params)
        ServiceResponse.success(
          message: 'Preference was updated',
          payload: { preferences: @preferences })
      else
        ServiceResponse.error(message: 'Could not update preference')
      end
    end

    private
    
  end
end
