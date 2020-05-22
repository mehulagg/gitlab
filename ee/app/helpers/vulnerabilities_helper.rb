# frozen_string_literal: true

module VulnerabilitiesHelper
  def vulnerability_data(vulnerability, pipeline)
    return unless vulnerability

    {
      vulnerability_json: VulnerabilitySerializer.new.represent(vulnerability).to_json,
      project_fingerprint: vulnerability.finding.project_fingerprint,
      create_issue_url: create_vulnerability_feedback_issue_path(vulnerability.finding.project),
      notes_url: project_security_vulnerability_notes_path(vulnerability.project, vulnerability),
      discussions_url: discussions_project_security_vulnerability_path(vulnerability.project, vulnerability),
      pipeline_json: vulnerability_pipeline_data(pipeline).to_json,
      has_mr: !!vulnerability.finding.merge_request_feedback.try(:merge_request_iid),
      vulnerability_feedback_help_path: help_page_path('user/application_security/index', anchor: 'interacting-with-the-vulnerabilities'),
      finding_json: vulnerability_finding_data(vulnerability.finding).to_json,
      create_mr_url: create_vulnerability_feedback_merge_request_path(vulnerability.finding.project),
      timestamp: Time.now.to_i
    }
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

  def vulnerability_finding_data(finding)
    finding = Vulnerabilities::FindingSerializer.new(current_user: current_user).represent(finding)
    remediation = finding[:remediations]&.first

    finding.slice(
      :description,
      :identifiers,
      :links,
      :location,
      :name,
      :issue_feedback,
      :merge_request_feedback,
      :project,
      :remediations
    ).merge(
      solution: remediation ? remediation['summary'] : finding[:solution]
    )
  end

  def vulnerability_file_link(vulnerability)
    finding = vulnerability.finding
    location = finding.location
    branch = finding.pipelines&.last&.sha || vulnerability.project.default_branch
    link_text = location['file']
    link_path = project_blob_path(vulnerability.project, tree_join(branch, location['file']))

    if location['start_line']
      link_text += ":#{location['start_line']}"
      link_path += "#L#{location['start_line']}"
    end

    link_to link_text, link_path, target: '_blank', rel: 'noopener noreferrer'
  end
end
