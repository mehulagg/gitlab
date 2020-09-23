# frozen_string_literal: true

module Projects
  module Licenses
    class UpdatePolicyService < ::BaseService
      def execute(policy_id)
        return error({}, :forbidden) unless can?(current_user, :admin_software_license_policy, project)
        return classification_error unless valid_classification?

        policy = project.software_license_policies.find(policy_id)
        change_classification_of(policy)
        success(software_license_policy: compliance_report_for(policy))
      rescue ActiveRecord::RecordInvalid => exception
        error(exception.record.errors, :unprocessable_entity)
      end

      private

      def change_classification_of(policy)
        if denied_classification?
          policy.denied!
        else
          policy.allowed!
        end

        RefreshLicenseComplianceChecksWorker.perform_async(project.id)
      end

      def compliance_report_for(policy)
        project.license_compliance.report_for(policy)
      end

      def classification_error
        errors = ActiveModel::Errors.new(SoftwareLicensePolicy.new)
        errors.add(:classification, :invalid)
        error(errors, :unprocessable_entity)
      end

      def valid_classification?
        SoftwareLicensePolicy.classifications.key?(params[:classification])
      end

      def denied_classification?
        params[:classification] == 'denied'
      end
    end
  end
end
