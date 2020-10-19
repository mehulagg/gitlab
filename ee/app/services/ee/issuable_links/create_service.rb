# frozen_string_literal: true

module EE
  module IssuableLinks
    module CreateService
      extend ::Gitlab::Utils::Override

      private

      override :link_issuables
      def link_issuables(objects)
        # it is important that this is not called after relate_issuables, as it relinks epic to the issuable
        # relate_issuables is called during the `super` portion of this method
        # see EpicLinks::EpicIssues#relate_issuables
        affected_epics = affected_epics(objects)

        super

        if !params[:skip_epic_dates_update] && affected_epics.present?
          Epics::UpdateDatesService.new(affected_epics).execute
        end
      end

      def affected_epics(_issues)
        []
      end
    end
  end
end
