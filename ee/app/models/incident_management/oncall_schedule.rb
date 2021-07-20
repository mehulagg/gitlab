# frozen_string_literal: true

module IncidentManagement
  class OncallSchedule < ApplicationRecord
    self.table_name = 'incident_management_oncall_schedules'

    include IidRoutes
    include AtomicInternalId

    NAME_LENGTH = 200
    DESCRIPTION_LENGTH = 1000

    belongs_to :project, inverse_of: :incident_management_oncall_schedules
    has_many :rotations, class_name: 'OncallRotation', inverse_of: :schedule
    has_many :participants, class_name: 'OncallParticipant', through: :rotations

    has_internal_id :iid, scope: :project

    validates :name, presence: true, uniqueness: { scope: :project }, length: { maximum: NAME_LENGTH }
    validates :description, length: { maximum: DESCRIPTION_LENGTH }
    validates :timezone, presence: true, inclusion: { in: :timezones }

    scope :for_iid, -> (iid) { where(iid: iid) }
    scope :for_project, -> (project) { where(project: project) }

    delegate :name, to: :project, prefix: true

    private

    def timezones
      @timezones ||= ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.identifier }
    end
  end
end
