# frozen_string_literal: true

namespace :gitlab do
  namespace :license do
    desc 'GitLab | License | Gather license related information'
    task info: :gitlab_environment do
      license = Gitlab::UsageData.license_usage_data
      abort("No license has been applied.") unless license[:license_plan]
      puts "Today's Date: #{Date.today}"
      puts "Current User Count: #{license[:active_user_count]}"
      puts "Max Historical Count: #{license[:historical_max_users]}"
      puts "Max Users in License: #{license[:license_user_count]}"
      puts "License valid from: #{license[:license_starts_at]} to #{license[:license_expires_at]}"
      puts "Email associated with license: #{license[:licensee]['Email']}"
    end

    task :load, [:mode] => :environment do |_, args|
      args.with_defaults(mode: 'default')
      verbose = args[:mode] == 'verbose'

      flag = 'GITLAB_LICENSE_FILE'

      if ENV[flag].blank? && verbose
        puts "Skipped. Use the `#{flag}` environment variable to seed the License file of the given path."
        next
      end

      default_license_file = Settings.source.dirname + 'Gitlab.gitlab-license'
      license_file = ENV.fetch(flag, default_license_file)

      if File.file?(license_file)
        if ::License.create(data: File.read(license_file))
          puts "License Added:\n\nFilePath: #{license_file}".color(:green)
        else
          puts "License Invalid:\n\nFilePath: #{license_file}".color(:red)
          raise "License Invalid"
        end
      elsif !ENV[flag].blank?
        puts "License File Missing:\n\nFilePath: #{license_file}".color(:red)
        raise "License File Missing"
      end
    end
  end
end
