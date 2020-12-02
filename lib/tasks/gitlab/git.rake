namespace :gitlab do
  namespace :git do
    desc 'GitLab | Git | Check all repos integrity'
    task fsck: :gitlab_environment do
      failures = []
      Project.find_each(batch_size: 100) do |project|
        begin
          project.repository.fsck

        rescue => e
          failures << "#{project.full_path} on #{project.repository_storage}: #{e}"
        end

        puts "Performed integrity check for #{project.repository.full_path}"
      end

      if failures.empty?
        puts "Done".color(:green)
      else
        puts "The following repositories reported errors:".color(:red)
        failures.each { |f| puts "- #{f}" }
      end
    end

    desc 'GitLab | Git | Check repos integrity, given a list of project IDs separated by newline in stdin'
    task fsck_projects: :gitlab_environment do
      failures = []

      STDIN.each do |line|
        project_id = line.to_i
        project = Project.find(project_id)

        begin
          project.repository.fsck
        rescue => e
          failures << "#{project.full_path} on #{project.repository_storage}: #{e}"
        end

        puts "Performed integrity check for #{project.repository.full_path}"
      end

      if failures.empty?
        puts "Done".color(:green)
      else
        puts "The following repositories reported errors:".color(:red)
        failures.each { |f| puts "- #{f}" }
      end
    end

    desc 'GitLab | Git | Generate checksum of project repository refs, given a list of project IDs separated by newline in stdin'
    task checksum_projects: :environment do |_t, args|
      STDIN.each do |line|
        project_id = line.to_i
        project = Project.find(project_id)
        checksum = project.repository.checksum

        $stdout.puts "#{project.id},#{checksum}"
      end
    end
  end
end
