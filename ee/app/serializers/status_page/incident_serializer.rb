# frozen_string_literal: true

module StatusPage
  class IncidentSerializer < BaseSerializer
    entity IncidentEntity

    def represent_list(resource)
      { incidents: represent(resource, except: [:comments, :description]) }
    end

    def represent_details(resource, user_notes)
      represent(resource, user_notes: user_notes, issue_iid: resource.iid)
    end

    private :represent
  end
end
