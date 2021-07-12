# frozen_string_literal: true

require './spec/support/sidekiq_middleware'

class Gitlab::Seeder::ComplianceDashboardMergeRequests
  PIPELINE_STATUSES = %w[success failed].freeze

  def initialize(project)
    @project = project
  end

  def admin
    @admin ||= FactoryBot.create(:user, :admin)
  end

  def seed!
    used_statuses = []

    merge_requests.each do |merge_request|
      branch = merge_request.source_branch
      commit = merge_request.diff_head_sha || @project.commit('HEAD')
      status = PIPELINE_STATUSES.reject { |s| used_statuses.include?(s) }.sample

      create_pipeline!(@project, branch, commit, status).tap do |pipeline|
        merge_request.update!(head_pipeline_id: pipeline.id)
      end

      EventCreateService.new.merge_mr(merge_request, merge_request.author)

      used_statuses.append(status)

      print '.'
    end
  end

  def merge_requests
    maintainer = new_maintainer
    developer = new_developer

    Array.new(2).map do
      amount = rand(1..2)
      approvers = [{ user: maintainer }]

      if amount === 2
        approvers = [{ user: developer }, { user: maintainer }]
      end

      create_merge_request!(approvers)
    end
  end

  def create_merge_request!(approvals)
    opts = {
      title: FFaker::Lorem.sentence(6),
      description: FFaker::Lorem.sentence,
      source_branch: "#{FFaker::Lorem.word}-#{SecureRandom.hex(5)}",
      target_branch: 'master',
      state: :opened
    }

    Sidekiq::Worker.skipping_transaction_check do
      merge_request = MergeRequests::CreateService.new(project: @project, current_user: admin, params: opts).execute
      merge_request.save!
      merge_request.approvals.create(approvals)
      merge_request.state = :merged

      merge_request
    end
  rescue ::Gitlab::Access::AccessDeniedError
    raise ::Gitlab::Access::AccessDeniedError, "If you are re-creating your GitLab database, you should also delete your old repositories located at $GDK/repositories/@hashed"
  end

  def create_pipeline!(project, ref, commit, status)
    project.ci_pipelines.create!(sha: commit.id, ref: ref, source: :push, status: status)
  end

  def new_developer
    developer = new_user

    @project.add_developer(developer)

    developer
  end

  def new_maintainer
    maintainer = new_user

    @project.add_maintainer(maintainer)

    maintainer
  end

  def new_user
    FactoryBot.create(:user)
  end
end

Gitlab::Seeder.quiet do
  projects = Project
      .non_archived
      .with_merge_requests_enabled
      .not_mass_generated
      .reject(&:empty_repo?)

  projects.each do |project|
    merge_requests = Gitlab::Seeder::ComplianceDashboardMergeRequests.new(project)
    merge_requests.seed!
  end
end
