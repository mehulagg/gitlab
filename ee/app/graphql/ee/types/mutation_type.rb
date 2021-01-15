# frozen_string_literal: true

module EE
  module Types
    module MutationType
      extend ActiveSupport::Concern

      prepended do
        mount_mutation ::Mutations::Clusters::Agents::Create
        mount_mutation ::Mutations::Clusters::Agents::Delete
        mount_mutation ::Mutations::Clusters::AgentTokens::Create
        mount_mutation ::Mutations::Clusters::AgentTokens::Delete
        mount_mutation ::Mutations::ComplianceManagement::Frameworks::Destroy
        mount_mutation ::Mutations::ComplianceManagement::Frameworks::Update
        mount_mutation ::Mutations::ComplianceManagement::Frameworks::Create
        mount_mutation ::Mutations::Issues::SetIteration
        mount_mutation ::Mutations::Issues::SetWeight
        mount_mutation ::Mutations::Issues::SetEpic
        mount_mutation ::Mutations::Issues::PromoteToEpic
        mount_mutation ::Mutations::EpicTree::Reorder
        mount_mutation ::Mutations::Epics::Update
        mount_mutation ::Mutations::Epics::Create
        mount_mutation ::Mutations::Epics::SetSubscription
        mount_mutation ::Mutations::Epics::AddIssue
        mount_mutation ::Mutations::Iterations::Create
        mount_mutation ::Mutations::Iterations::Update
        mount_mutation ::Mutations::RequirementsManagement::CreateRequirement
        mount_mutation ::Mutations::RequirementsManagement::ExportRequirements
        mount_mutation ::Mutations::RequirementsManagement::UpdateRequirement
        mount_mutation ::Mutations::Vulnerabilities::Dismiss
        mount_mutation ::Mutations::Vulnerabilities::Resolve
        mount_mutation ::Mutations::Vulnerabilities::Confirm
        mount_mutation ::Mutations::Vulnerabilities::RevertToDetected
        mount_mutation ::Mutations::Vulnerabilities::CreateExternalIssueLink
        mount_mutation ::Mutations::Vulnerabilities::DestroyExternalIssueLink
        mount_mutation ::Mutations::Boards::Update
        mount_mutation ::Mutations::Boards::Lists::UpdateLimitMetrics
        mount_mutation ::Mutations::Boards::UpdateEpicUserPreferences
        mount_mutation ::Mutations::InstanceSecurityDashboard::AddProject
        mount_mutation ::Mutations::InstanceSecurityDashboard::RemoveProject
        mount_mutation ::Mutations::DastOnDemandScans::Create
        mount_mutation ::Mutations::DastSiteProfiles::Create
        mount_mutation ::Mutations::DastSiteProfiles::Update
        mount_mutation ::Mutations::DastSiteProfiles::Delete
        mount_mutation ::Mutations::DastSiteValidations::Create
        mount_mutation ::Mutations::DastSiteValidations::Revoke
        mount_mutation ::Mutations::DastScannerProfiles::Create
        mount_mutation ::Mutations::DastScannerProfiles::Update
        mount_mutation ::Mutations::DastScannerProfiles::Delete
        mount_mutation ::Mutations::DastSiteTokens::Create
        mount_mutation ::Mutations::Security::CiConfiguration::ConfigureSast
        mount_mutation ::Mutations::Namespaces::IncreaseStorageTemporarily
        mount_mutation ::Mutations::QualityManagement::TestCases::Create
        mount_mutation ::Mutations::Admin::Analytics::DevopsAdoption::Segments::Create
        mount_mutation ::Mutations::Admin::Analytics::DevopsAdoption::Segments::Update
        mount_mutation ::Mutations::Admin::Analytics::DevopsAdoption::Segments::Delete
        mount_mutation ::Mutations::IncidentManagement::OncallSchedule::Create
        mount_mutation ::Mutations::IncidentManagement::OncallSchedule::Update
        mount_mutation ::Mutations::IncidentManagement::OncallSchedule::Destroy
        mount_mutation ::Mutations::IncidentManagement::OncallRotation::Create

        prepend(Types::DeprecatedMutations)
      end
    end
  end
end
