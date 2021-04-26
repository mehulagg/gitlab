# frozen_string_literal: true

class IssueRebalancingWorker
  include ApplicationWorker

  idempotent!
  urgency :low
  feature_category :issue_tracking
  deduplicate :until_executed, including_scheduled: true

  def perform(ignore = nil, project_id = nil, root_namespace_id = nil)
    return if project_id.nil? && root_namespace_id.nil?

    # pull root namespace if we get a project_id or a namespace_id,
    # this makes the worker backward compatible with previous version
    root_namespace = root_namespace(project_id, root_namespace_id)

    # something might have happened with the namespace between scheduling the worker and actually running it,
    # maybe it was removed.
    unless root_namespace
      Gitlab::ErrorTracking.log_exception(
        ArgumentError.new("Root namespace not found for arguments: project_id #{project_id}, root_namespace_id: #{root_namespace_id}"),
        { project_id: project_id, root_namespace_id: root_namespace_id})

      return
    end

    IssueRebalancingService.new(root_namespace).execute
  rescue IssueRebalancingService::TooManyIssues => e
    # cannot use root_namespace_id as root_namespace may be coming from project_id, which would be different from root_namespace_id
    Gitlab::ErrorTracking.log_exception(e, root_namespace_id: root_namespace.id)
  end

  private

  def root_namespace(project_id, root_namespace_id)
    root_namespace = Project.find_by_id(project_id)&.root_namespace if project_id
    root_namespace ||= Namespace.find_by_id(root_namespace_id) if root_namespace_id

    root_namespace
  end
end
