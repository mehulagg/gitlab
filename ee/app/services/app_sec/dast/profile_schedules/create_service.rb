# frozen_string_literal: true

module AppSec
  module Dast
    module ProfileSchedules
      class CreateService < BaseContainerService
        def execute
          return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

          schedule = Dast::ProfileSchedule.new(
            user: current_user,
            dast_profile: dast_profile_schedule.fetch(:dast_site_profile),
            project_id: container
          )

          #TODO: Write logic to convert date to cron.
          # This logic will also take care of setting repeats: false
          schedule.cron = parse_to_cron
          schedule.next_run_at = Time.zone.now - 1.minutes
          schedule.save!

          create_audit_event(schedule)

          ServiceResponse.success(payload: { dast_profile_schedule: schedule })
        rescue ActiveRecord::RecordInvalid => err
          ServiceResponse.error(message: err.record.errors.full_messages)
        rescue KeyError => err
          ServiceResponse.error(message: err.message.capitalize)
        end

        private

        def allowed?
          container.licensed_feature_available?(:security_on_demand_scans)
        end

        def repeats?
          repeat_cycle != 'none'
        end

        def parse_to_cron
          return '* * * *' unless repeats?

          # TODO
        end

        def create_audit_event(schedule)
          ::Gitlab::Audit::Auditor.audit(
            name: 'dast_profile_schedule_create',
            author: current_user,
            scope: container,
            target: schedule,
            message: "Added DAST profile schedule"
          )
        end

        def repeat_cycle
          @repeats ||= dast_profile_schedule.fetch(:repeats)
        end

        def starts_at
          @starts_at ||= dast_profile_schedule.fetch(:starts_at).to_datetime
        end

        def dast_profile_schedule
          @schedule ||= params.fetch(:dast_profile_schedule)
        end
      end
    end
  end
end
