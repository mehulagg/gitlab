# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Licenses::UpdatePolicyService do
  subject { described_class.new(project, user, params) }

  let(:project) { create(:project, :repository, :private) }
  let(:user) { create(:user) }

  describe "#execute" do
    let(:policy) { create(:software_license_policy, :denied, project: project, software_license: mit_license) }
    let(:mit_license) { create(:software_license, :mit) }

    context "when the user is authorized" do
      before do
        allow(RefreshLicenseComplianceChecksWorker).to receive(:perform_async)
        stub_licensed_features(license_scanning: true)
        project.add_maintainer(user)
      end

      context "when updating a policy" do
        let(:params) { { classification: "allowed" } }

        it "updates the policy" do
          result = subject.execute(policy.id)

          expect(result[:status]).to eq(:success)
          expect(result[:software_license_policy]).to be_present
          expect(result[:software_license_policy].classification).to eq('allowed')
          expect(RefreshLicenseComplianceChecksWorker).to have_received(:perform_async).with(project.id)
        end
      end

      context "when the classification is invalid" do
        let(:params) { { classification: 'invalid' } }

        it "returns an error" do
          result = subject.execute(policy.id)

          expect(result[:status]).to eq(:error)
          expect(result[:message]).to be_instance_of(ActiveModel::Errors)
          expect(result[:http_status]).to eq(:unprocessable_entity)
          expect(RefreshLicenseComplianceChecksWorker).not_to have_received(:perform_async).with(project.id)
        end
      end
    end

    context "when the user is not authorized" do
      context "when updating a policy" do
        let(:params) { { classification: "approved" } }

        it "returns an error" do
          result = subject.execute(policy.id)

          expect(result[:status]).to eq(:error)
          expect(result[:message]).to be_empty
          expect(result[:http_status]).to eq(:forbidden)
        end
      end
    end
  end
end
