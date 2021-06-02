# frozen_string_literal: true

module EE
  module API
    module UpcomingReconciliations
      extend ActiveSupport::Concern

      prepended do
        helpers do
          def update_upcoming_reconciliations
            service = ::UpcomingReconciliations::UpdateService.new(upcoming_reconciliations)
            response = service.execute

            if response.success?
              present response
            else
              render_api_error!({ error: response.error }, 400)
            end
          end
        end

        resource :upcoming_reconciliations do
          desc 'Update upcoming reconciliations' do
            #success Entities::UpcomingReconciliation #TODO: what is success? do we need this?
            # We won't return any UpcomingREconciliation entity, we will just return `response ok`
          end
          params do
            requires :upcoming_reconciliations, type: Hash, desc: 'The upcoming reconciliations'
          end

          put '/' do
            authenticated_as_admin!

            update_upcoming_reconciliations
          end
        end
      end
    end
  end
end
