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

    after_create :backfill_escalation_policy

    def default_escalation_rule
      EscalationRule.new(
        elapsed_time_seconds: 0,
        oncall_schedule: self,
        status: :acknowledged
      )
    end

    private

    def timezones
      @timezones ||= ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.identifier }
    end

    # While escalation policies are in development, we want to
    # backfill a policy for any project with an OncallSchedule.
    # Once escalation policies are enabled, users will need to
    # configure a policy directly in order to direct alerts
    # to a schedule.
    def backfill_escalation_policy
      return if ::Feature.enabled?(:escalation_policies_mvc, project, default_enabled: :yaml)
      return if ::Feature.disabled?(:escalation_policies_backfill, project, default_enabled: :yaml)

      if policy = project.incident_management_escalation_policies.first
        policy.rules << default_escalation_rule
      else
        EscalationPolicy.create!(
          project: project,
          name: 'On-call Escalation Policy',
          description: "Immediately notify #{name}",
          rules: project.incident_management_oncall_schedules.map(&:default_escalation_rule)
        )
      end
    end
  end
end
