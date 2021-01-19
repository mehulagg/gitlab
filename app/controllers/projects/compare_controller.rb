# frozen_string_literal: true

require 'addressable/uri'

class Projects::CompareController < Projects::ApplicationController
  include DiffForPath
  include DiffHelper
  include RendersCommits

  # Authorize
  before_action :require_non_empty_project
  before_action :authorize_download_code!
  # Defining ivars
  before_action :define_diffs, only: [:show, :diff_for_path]
  before_action :define_environment, only: [:show]
  before_action :define_diff_notes_disabled, only: [:show, :diff_for_path]
  before_action :define_commits, only: [:show, :diff_for_path, :signatures]
  before_action :merge_request, only: [:index, :show]
  # Validation
  before_action :validate_refs!

  feature_category :source_code_management

  def index
  end

  def show
    apply_diff_view_cookie!

    render
  end

  def diff_for_path
    return render_404 unless compare

    render_diff_for_path(compare.diffs(diff_options))
  end

  # TODO: Do we want to use `remote:branch`-style params instead of adding `source_project_id`?
  def create
    if params[:from].blank? || params[:to].blank?
      flash[:alert] = "You must select a Source and a Target revision"

      from_to_vars = params.slice(:from, :to, :source_project_id)
      redirect_to project_compare_index_path(target_project, from_to_vars)
    else
      redirect_to project_compare_path(target_project, params[:from], params[:to], source_project_id: params[:source_project_id])
    end
  end

  def signatures
    respond_to do |format|
      format.json do
        render json: {
          signatures: @commits.select(&:has_signature?).map do |commit|
            {
              commit_sha: commit.sha,
              html: view_to_html_string('projects/commit/_signature', signature: commit.signature)
            }
          end
        }
      end
    end
  end

  private

  def validate_refs!
    valid = [head_ref, start_ref].map { |ref| valid_ref?(ref) }

    return if valid.all?

    flash[:alert] = "Invalid branch name"
    redirect_to project_compare_index_path(target_project)
  end

  def source_project
    strong_memoize(:source_project) do
      if params.key?(:source_project_id)
        Project.find(params[:source_project_id])
      else
       target_project
      end
    end
  end

  def target_project
    @project
  end

  def compare
    return @compare if defined?(@compare)

    @compare = CompareService.new(source_project, head_ref).execute(target_project, start_ref)
  end

  # start_ref = from = target
  def start_ref
    @start_ref ||= Addressable::URI.unescape(params[:from])
  end

  # head_ref = to = source
  def head_ref
    return @ref if defined?(@ref)

    @ref = @head_ref = Addressable::URI.unescape(params[:to])
  end

  def define_commits
    @commits = compare.present? ? set_commits_for_rendering(@compare.commits) : []
  end

  def define_diffs
    @diffs = compare.present? ? compare.diffs(diff_options) : []
  end

  # FIXME: check if we want to be using source or target project here
  def define_environment
    if compare
      environment_params = source_project.repository.branch_exists?(head_ref) ? { ref: head_ref } : { commit: compare.commit }
      environment_params[:find_latest] = true
      @environment = EnvironmentsFinder.new(source_project, current_user, environment_params).execute.last
    end
  end

  def define_diff_notes_disabled
    @diff_notes_disabled = compare.present?
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def merge_request
    @merge_request ||= MergeRequestsFinder.new(current_user, project_id: target_project.id).execute.opened
      .find_by(source_project: source_project, source_branch: head_ref, target_branch: start_ref)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
