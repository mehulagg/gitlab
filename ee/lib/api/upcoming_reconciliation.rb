# frozen_string_literal: true

module API
  class UpcomingReconciliations < ::API::Base
    before { authenticated_as_admin! }

    feature_category :purchase

    resource :upcoming_reconciliations do
      desc 'Update upcoming reconciliations'
      params do
        requires :upcoming_reconciliations, type: Hash, desc: 'The upcoming reconciliations'
      end

      put '/' do
        service = ::UpcomingReconciliations::UpdateService.new(upcoming_reconciliations)
        response = service.execute

        if response.success?
          status 200
        else
          render_api_error!({ error: response.errors.first }, 400)
        end
      end
    end
  end
end
