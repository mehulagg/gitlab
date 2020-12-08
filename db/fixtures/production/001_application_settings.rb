# frozen_string_literal: true

puts "Creating the default ApplicationSetting record.".color(:green)
Gitlab::CurrentSettings.current_application_settings

puts "Set the default branch name.".color(:green)
ApplicationSetting.current_without_cache.update!(default_branch_name: 'main')
