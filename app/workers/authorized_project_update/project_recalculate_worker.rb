# frozen_string_literal: true

module AuthorizedProjectUpdate
  class ProjectRecalculateWorker
    include ApplicationWorker

    sidekiq_options retry: 3

    feature_category :authentication_and_authorization
    urgency :high
    queue_namespace :authorized_projects

    deduplicate :until_executing, including_scheduled: true
    idempotent!

    def perform(project_id)
      project = Project.find(project_id)

      AuthorizedProjectUpdate::ProjectRecalculateService.new(project).execute
    end
  end
end
