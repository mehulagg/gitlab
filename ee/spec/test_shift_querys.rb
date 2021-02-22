# frozen_string_literal: true

require 'spec_helper'
require 'activerecord-explain-analyze'

RSpec.describe Projects::Alerting::NotifyService do
  INDEX_NAME = 'index_incident_management_oncall_participants_is_removed'

  before_all do
    # ActiveRecord::Migration.remove_index :incident_management_oncall_participants, name: INDEX_NAME
    ActiveRecord::Migration.remove_index :incident_management_oncall_participants, name: 'index_inc_mgmnt_oncall_participants_on_oncall_rotation_id'
    ActiveRecord::Migration.add_index :incident_management_oncall_participants, [:oncall_rotation_id, :is_removed], name: 'index_inc_mgmnt_oncall_participants_on_oncall_rotation_id'

    25.times { create_project_with_oncall }
    @project = create_project_with_oncall
    10.times { create_project_with_oncall }

    p "#{Time.current} - Done generating projects."
  end

  # after(:all) do
  #   ActiveRecord::Migration.add_index :incident_management_oncall_participants, :is_removed, name: INDEX_NAME
  # end

  describe 'shift finding query' do
    def query(scenario, query_time)
      puts "\n\n\nSHIFT-FINDING QUERY EXPLAIN - #{scenario}\n\n"
      puts @project.incident_management_oncall_rotations
            .merge(IncidentManagement::OncallShift.for_timestamp(query_time))
            .joins(shifts: { participant: :user })
            .explain(analyze: true)
    end

    it 'pre-rotation start' do query('pre-rotation start', 7.months.ago) end
    it 'in the recent past' do query('in the recent past', 2.days.ago) end
    it 'in the future' do query('in the future', 3.months.from_now) end
    it 'at the current time' do query('at the current time', Time.current) end
  end

  describe 'shift generating query' do
    def query(scenario, query_time)
      puts "\n\n\nSHIFT-GENERATING QUERY EXPLAIN - #{scenario}\n\n"
      puts ::IncidentManagement::OncallUsersFinder.new(
        @project,
        oncall_at: query_time
      ).send(:rotations_without_persisted_shifts).explain(analyze: true)
    end

    it 'pre-rotation start' do query('pre-rotation start', 7.months.ago) end
    it 'in the recent past' do query('in the recent past', 2.days.ago) end
    it 'in the future' do query('in the future', 3.months.from_now) end
    it 'at the current time' do query('at the current time', Time.current) end
  end

  describe 'users query' do
    def query(query_time)
      puts "\n\n\nUSERS QUERY EXPLAIN\n\n"
      puts User.id_in(
        ::IncidentManagement::OncallUsersFinder.new(
          @project,
          oncall_at: query_time
        ).send(:user_ids)
      ).explain(analyze: true)
    end

    it 'default query' do query(Time.current) end

    it 'lets me do extra queries' do
      binding.pry
    end
  end

  private

  def create_project_with_oncall
    project = create(:project)
    p "#{Time.current} - Creating project: #{project.id}"

    schedule_count = rand(1..5)
    create_list(:incident_management_oncall_schedule, schedule_count, project: project) do |schedule|
      rotation_count = rand(1..5)

      schedule.rotations = create_list(:incident_management_oncall_rotation, rotation_count, schedule: schedule) do |rotation|
        rotation.update(
          starts_at: rand(6.months.ago..1.month.from_now),
          length_unit: [:hours, :days, :weeks].sample,
          length: rand(1..12),
          ends_at: [true, false].sample ? rotation.starts_at + rand(1.month..6.months) : nil
        )
        participant_count = rand(3..25)
        rotation.participants = create_list(:incident_management_oncall_participant, participant_count, :with_developer_access, rotation: rotation)

        IncidentManagement::OncallShift.bulk_insert!(
          IncidentManagement::OncallShiftGenerator.new(rotation).for_timeframe(
            starts_at: rotation.starts_at,
            ends_at: rand(5.hours.ago..5.hours.from_now)
          )
        )
      end
    end

    p "#{Time.current} - IncidentManagement::OncallShifts: #{IncidentManagement::OncallShift.count}"
    p "#{Time.current} - IncidentManagement::OncallParticipants: #{IncidentManagement::OncallParticipant.count}"
    p "#{Time.current} - IncidentManagement::OncallRotations: #{IncidentManagement::OncallRotation.count}"
    p "#{Time.current} - IncidentManagement::OncallSchedules: #{IncidentManagement::OncallSchedule.count}"

    project
  end
end
