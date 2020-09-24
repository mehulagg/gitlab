# frozen_string_literal: true

module VulnerableHelpers
  class BadVulnerableError < StandardError
    def message
      'The given vulnerable must be either `Project`, `Namespace`, or `InstanceSecurityDashboard`'
    end
  end

  def as_vulnerable_project(vulnerable)
    case vulnerable
    when Project
      vulnerable
    when Namespace
      create(:project, namespace: vulnerable)
    when InstanceSecurityDashboard
      Project.find(vulnerable.project_ids_with_security_reports.first)
    else
      raise BadVulnerableError
    end
  end
end
