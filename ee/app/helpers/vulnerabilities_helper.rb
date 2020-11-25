# frozen_string_literal: true

module VulnerabilitiesHelper
  def vulnerability_details_json(vulnerability, pipeline)
    vulnerability_details(vulnerability, pipeline).to_json
  end

  def vulnerability_details(vulnerability, pipeline)
    return unless vulnerability

    result = {
      timestamp: Time.now.to_i,
      create_issue_url: create_issue_url_for(vulnerability),
      create_jira_issue_url: create_jira_issue_url_for(vulnerability),
      related_jira_issues_path: project_integrations_jira_issues_path(vulnerability.project, vulnerability_ids: [vulnerability.id]),
      has_mr: !!vulnerability.finding.merge_request_feedback.try(:merge_request_iid),
      create_mr_url: create_vulnerability_feedback_merge_request_path(vulnerability.finding.project),
      discussions_url: discussions_project_security_vulnerability_path(vulnerability.project, vulnerability),
      notes_url: project_security_vulnerability_notes_path(vulnerability.project, vulnerability),
      related_issues_help_path: help_page_path('user/application_security/index', anchor: 'managing-related-issues-for-a-vulnerability'),
      pipeline: vulnerability_pipeline_data(pipeline),
      can_modify_related_issues: current_user.can?(:admin_vulnerability_issue_link, vulnerability),
      issue_tracking_help_path: help_page_path('user/project/settings', anchor: 'sharing-and-permissions'),
      permissions_help_path: help_page_path('user/permissions', anchor: 'project-members-permissions')
    }

    result.merge(vulnerability_data(vulnerability), vulnerability_finding_data(vulnerability))
  end

  def create_issue_url_for(vulnerability)
    return unless vulnerability.project.issues_enabled?

    create_issue_project_security_vulnerability_path(vulnerability.project, vulnerability)
  end

  def create_jira_issue_url_for(vulnerability)
    return unless vulnerability.project.jira_vulnerabilities_integration_enabled?

    summary = _('Investigate vulnerability: %{title}') % { title: vulnerability.title }
    description = ApplicationController.render(template: 'vulnerabilities/jira_issue_description.md.erb',
                                               locals: { vulnerability: vulnerability.present })

    vulnerability.project.jira_service.new_issue_url_with_predefined_fields(summary, description)
  end

  def vulnerability_pipeline_data(pipeline)
    return unless pipeline

    {
      id: pipeline.id,
      created_at: pipeline.created_at.iso8601,
      url: pipeline_path(pipeline),
      source_branch: pipeline.ref
    }
  end

  def vulnerability_data(vulnerability)
    VulnerabilitySerializer.new.represent(vulnerability)
  end

  def vulnerability_finding_data(vulnerability)
    finding = Vulnerabilities::FindingSerializer.new(current_user: current_user).represent(vulnerability.finding)

    data = finding.slice(
      :description,
      :identifiers,
      :links,
      :location,
      :name,
      :issue_feedback,
      :merge_request_feedback,
      :project,
      :project_fingerprint,
      :remediations,
      :evidence,
      :scanner,
      :solution,
      :request,
      :response,
      :evidence_source,
      :supporting_messages,
      :assets
    )

    if data[:location]['file']
      branch = vulnerability.finding.pipelines&.last&.sha || vulnerability.project.default_branch
      path = project_blob_path(vulnerability.project, tree_join(branch, data[:location]['file']))

      data[:location]['blob_path'] = path
    end

    data
  end
end
