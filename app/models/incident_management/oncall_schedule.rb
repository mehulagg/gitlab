# frozen_string_literal: true

module IncidentManagement
  class OncallSchedule < ApplicationRecord
    self.table_name = 'incident_management_oncall_schedules'

    include IidRoutes
    include AtomicInternalId

    NAME_LENGTH = 200
    DESCRIPTION_LENGTH = 1000
    TIMEZONE_LENGTH = 100

    belongs_to :project, inverse_of: :incident_management_oncall_schedules

    has_internal_id :iid, scope: :project

    validates :name, presence: true, length: { maximum: NAME_LENGTH }
    validates :description, length: { maximum: DESCRIPTION_LENGTH }
    validates :timezone, presence: true, length: { maximum: TIMEZONE_LENGTH }
  end
end
