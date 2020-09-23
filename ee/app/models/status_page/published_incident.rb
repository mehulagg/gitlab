# frozen_string_literal: true

module StatusPage
  # Corresponds to an issue which has been published to the Status Page.
  class PublishedIncident < ApplicationRecord
    self.table_name = "status_page_published_incidents"

    belongs_to :issue, inverse_of: :status_page_published_incident
    validates :issue, presence: true

    def self.track(issue)
      safe_find_or_create_by(issue: issue)
    end

    def self.untrack(issue)
      find_by(issue: issue)&.destroy
    end
  end
end
