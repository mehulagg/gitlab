# frozen_string_literal: true

# require './spec/support/sidekiq_middleware'

Gitlab::Seeder.quiet do
  groups = Group.take(5)

  return if groups.empty?

  segment_groups_1 = groups.sample(2)
  segment_groups_2 = groups.sample(3)

  ActiveRecord::Base.transaction do
    segment_1 = Analytics::DevopsAdoption::Segments::CreateService.new(params: { name: 'Segment 1', groups: segment_groups_1 }).execute
    segment_2 = Analytics::DevopsAdoption::Segments::CreateService.new(params: { name: 'Segment 2', groups: segment_groups_2 }).execute

    segments = [segment_1, segment_2]

    # Ensure that the records are saved
    segments.each(&:save!)

    booleans = [true, false]

    # create snapshots for the last 5 months
    5.downto(1).each do |index|
      recorded_at = index.months.ago.at_end_of_month 

      segments.each do |segment|
        Analytics::DevopsAdoption::Snapshot.create!(
          segment: segment,
          issue_opened: booleans.sample,
          merge_request_opened: booleans.sample,
          merge_request_approved: booleans.sample,
          runner_configured: booleans.sample,
          pipeline_succeeded: booleans.sample,
          deploy_succeeded: booleans.sample,
          security_scan_succeeded: booleans.sample,
          recorded_at: recorded_at
        )

        segment.update!(last_recorded_at: recorded_at)
      end
    end
  end

  print '.'
end

