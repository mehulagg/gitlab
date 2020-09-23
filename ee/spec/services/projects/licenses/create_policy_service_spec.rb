# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Licenses::CreatePolicyService do
  subject { described_class.new(project, user, params) }

  let_it_be(:project) { create(:project, :repository, :private) }
  let_it_be(:user) { create(:user) }

  describe "#execute" do
    let_it_be(:mit_license) { create(:software_license, :mit) }

    before do
      allow(RefreshLicenseComplianceChecksWorker).to receive(:perform_async)
    end

    context "when creating a policy for a software license by the software license database id" do
      let(:params) do
        {
          software_license_id: mit_license.id,
          classification: 'allowed'
        }
      end

      it 'creates a new policy' do
        result = subject.execute

        expect(result[:status]).to eq(:success)
        expect(result[:software_license_policy]).to be_present
        expect(result[:software_license_policy].id).to be_present
        expect(result[:software_license_policy].spdx_identifier).to eq(mit_license.spdx_identifier)
        expect(result[:software_license_policy].classification).to eq('allowed')
        expect(result[:software_license_policy].name).to eq(mit_license.name)
        expect(result[:software_license_policy].url).to be_nil
        expect(result[:software_license_policy].dependencies).to be_empty
        expect(RefreshLicenseComplianceChecksWorker).to have_received(:perform_async).with(project.id)
      end
    end

    context "when creating a policy for a software license by the software license SPDX identifier" do
      let(:params) do
        {
          spdx_identifier: mit_license.spdx_identifier,
          classification: 'denied'
        }
      end

      it 'creates a new policy' do
        result = subject.execute

        expect(result[:status]).to eq(:success)
        expect(result[:software_license_policy]).to be_present
        expect(result[:software_license_policy].id).to be_present
        expect(result[:software_license_policy].spdx_identifier).to eq(mit_license.spdx_identifier)
        expect(result[:software_license_policy].classification).to eq('denied')
        expect(result[:software_license_policy].name).to eq(mit_license.name)
        expect(result[:software_license_policy].url).to be_nil
        expect(result[:software_license_policy].dependencies).to be_empty
        expect(RefreshLicenseComplianceChecksWorker).to have_received(:perform_async).with(project.id)
      end
    end

    context "when the software license is not specified" do
      let(:params) do
        {
          spdx_identifier: nil,
          classification: 'denied'
        }
      end

      it 'returns an error' do
        result = subject.execute

        expect(result[:status]).to eq(:error)
        expect(result[:message]).to be_instance_of(ActiveModel::Errors)
        expect(result[:http_status]).to eq(:unprocessable_entity)
        expect(RefreshLicenseComplianceChecksWorker).not_to have_received(:perform_async)
      end
    end

    context "when the classification is invalid" do
      let(:params) do
        {
          spdx_identifier: mit_license.spdx_identifier,
          classification: 'invalid'
        }
      end

      it 'returns an error' do
        result = subject.execute

        expect(result[:status]).to eq(:error)
        expect(result[:message]).to be_instance_of(ActiveModel::Errors)
        expect(result[:http_status]).to eq(:unprocessable_entity)
        expect(RefreshLicenseComplianceChecksWorker).not_to have_received(:perform_async)
      end
    end
  end
end
