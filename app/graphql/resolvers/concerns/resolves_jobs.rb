# frozen_string_literal: true

module ResolvesJobs
  extend ActiveSupport::Concern

  included do
    type Types::Ci::JobType.connection_type, null: false
  end

  def resolve_jobs(project, params = {})
    Ci::JobsFinder.new(current_user: current_user, project: project, params: params).execute
  end
end
