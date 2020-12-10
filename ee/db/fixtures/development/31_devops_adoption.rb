# frozen_string_literal: true

Gitlab::Seeder.quiet do
  admin = User.where(admin: true).first

  if admin.nil?
    puts "No admin user present"
    next
  end

  groups = Group.take(5)

  next if groups.empty?

  segment_groups_1 = groups.sample(2)
  segment_groups_2 = groups.sample(3)

  ActiveRecord::Base.transaction do
    segment_1 = Analytics::DevopsAdoption::Segments::CreateService.new(params: { name: 'Segment 1', groups: segment_groups_1 }, current_user: admin).execute
    segment_2 = Analytics::DevopsAdoption::Segments::CreateService.new(params: { name: 'Segment 2', groups: segment_groups_2 }, current_user: admin).execute

    segments = [segment_1.payload[:segment], segment_2.payload[:segment]]

    if segments.any?(&:invalid?)
      puts "Error creating segments"
      puts "#{segments.map(&:errors)}"
      next
    end

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
