# frozen_string_literal: true

class Dast::ProfileSchedule < ApplicationRecord
  include CronSchedulable

  self.table_name = 'dast_profile_schedules'
  
  belongs_to :dast_profile, class_name: 'Dast::Profile', optional: false, inverse_of: :dast_profile_schedules
  # TODO: Change to user_id
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'

  validates :cron, presence: true
  validates :cron_timezone, presence: true

  scope :active, -> { where(active: true) }
  scope :with_profile_project, -> { includes(dast_profile: :project)} 

  # Runnable schedules should be active too.
  scope :runnable_schedules, -> { active.where("next_run_at < ?", Time.zone.now) }
  scope :with_owner, -> { includes(:owner) }

  def profile
    @profile ||= self.dast_profile
  end

  def project
    @project ||= profile.project
  end

  private

  def cron_timezone
    Time.zone.name
  end

  def worker_cron_expression
    Settings.cron_jobs['dast_profile_schedule_worker']['cron']
  end
end
