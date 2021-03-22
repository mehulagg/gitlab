# frozen_string_literal: true

module ResolvesJobs
  extend ActiveSupport::Concern

  included do
    type Types::Ci::JobType.connection_type, null: false
  end

  # todo: Wat is this?
  class_methods do
    def resolver_complexity(args, child_complexity:)
      complexity = super
      complexity += 2 if args[:sha]
      complexity += 2 if args[:ref]

      complexity
    end
  end

  def resolve_jobs(project, params = {})
    # Ci::JobsFinder.new(project, context[:current_user], params).execute
    # Ci::JobsFinder.new(project, current_user: @current_user).execute
    Ci::JobsFinder.new(current_user: current_user, project: project, params: params).execute
  end
end
