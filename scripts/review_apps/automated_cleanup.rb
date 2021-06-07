# frozen_string_literal: true

require 'gitlab'

class AutomatedCleanup
  attr_reader :project_path, :gitlab_token

  DEPLOYMENTS_PER_PAGE = 100

  # $GITLAB_PROJECT_REVIEW_APP_CLEANUP_API_TOKEN => `Automated Review App Cleanup` project token
  def initialize(project_path: ENV['CI_PROJECT_PATH'], gitlab_token: ENV['GITLAB_PROJECT_REVIEW_APP_CLEANUP_API_TOKEN'])
    @project_path = project_path
    @gitlab_token = gitlab_token
  end

  def gitlab
    @gitlab ||= begin
      Gitlab.configure do |config|
        config.endpoint = 'https://gitlab.com/api/v4'
        # gitlab-bot's token "GitLab review apps cleanup"
        config.private_token = gitlab_token
      end

      Gitlab
    end
  end

  def perform_gitlab_environment_cleanup!(days_for_stop:, days_for_delete:)
    puts "Checking for Review Apps not updated in the last #{days_for_stop} days..."

    checked_environments = []
    delete_threshold = threshold_time(days: days_for_delete)
    stop_threshold = threshold_time(days: days_for_stop)
    deployments_look_back_threshold = threshold_time(days: days_for_delete * 5)

    gitlab.deployments(project_path, per_page: DEPLOYMENTS_PER_PAGE, sort: 'desc').auto_paginate do |deployment|
      break if Time.parse(deployment.created_at) < deployments_look_back_threshold

      environment = deployment.environment

      next unless environment
      next unless environment.name.start_with?('review/')
      next if checked_environments.include?(environment.slug)

      last_deploy = deployment.created_at
      deployed_at = Time.parse(last_deploy)

      if deployed_at < delete_threshold
        delete_environment(environment, deployment)
      elsif deployed_at < stop_threshold
        environment_state = fetch_environment(environment)&.state
        stop_environment(environment, deployment) if environment_state && environment_state != 'stopped'
      else
        print_release_state(subject: 'Review App', release_name: environment.slug, release_date: last_deploy, action: 'leaving')
      end

      checked_environments << environment.slug
    end
  end

  private

  def fetch_environment(environment)
    gitlab.environment(project_path, environment.id)
  rescue Errno::ETIMEDOUT => ex
    puts "Failed to fetch '#{environment.name}' / '#{environment.slug}' (##{environment.id}):\n#{ex.message}"
    nil
  end

  def delete_environment(environment, deployment)
    print_release_state(subject: 'Review app', release_name: environment.slug, release_date: deployment.created_at, action: 'deleting')
    gitlab.delete_environment(project_path, environment.id)

  rescue Gitlab::Error::Forbidden
    puts "Review app '#{environment.name}' / '#{environment.slug}' (##{environment.id}) is forbidden: skipping it"
  end

  def stop_environment(environment, deployment)
    print_release_state(subject: 'Review app', release_name: environment.slug, release_date: deployment.created_at, action: 'stopping')
    gitlab.stop_environment(project_path, environment.id)

  rescue Gitlab::Error::Forbidden
    puts "Review app '#{environment.name}' / '#{environment.slug}' (##{environment.id}) is forbidden: skipping it"
  end

  def threshold_time(days:)
    Time.now - days * 24 * 3600
  end

  def print_release_state(subject:, release_name:, release_date:, action:, release_status: nil)
    puts "\n#{subject} '#{release_name}' #{"(#{release_status}) " if release_status}was last deployed on #{release_date}: #{action} it.\n"
  end
end

def timed(task)
  start = Time.now
  yield(self)
  puts "#{task} finished in #{Time.now - start} seconds.\n"
end

automated_cleanup = AutomatedCleanup.new

timed('Review Apps cleanup') do
  automated_cleanup.perform_gitlab_environment_cleanup!(days_for_stop: 5, days_for_delete: 6)
end

exit(0)
