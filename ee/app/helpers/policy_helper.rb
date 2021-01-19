# frozen_string_literal: true

module PolicyHelper
  def policy_details(project, *args)
    return unless project

    details = {
      network_policies_endpoint: project_security_network_policies_path(project),
      configure_agent_help_path: help_page_url('user/clusters/agent/repository.html'),
      create_agent_help_path: help_page_url('user/clusters/agent/index.md', anchor: 'create-an-agent-record-in-gitlab'),
      environments_endpoint: project_environments_path(project),
      project_path: project.full_path,
      threat_monitoring_path: project_threat_monitoring_path(project),
    }

    return details unless args.size > 0

    edit_details = {
      policy: args.policy.to_json,
      environment_id: args.environment.id,
    }
    details.merge(edit_details)
  end
end
