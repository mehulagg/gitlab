# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DastSiteProfiles::Create do
  let(:group) { create(:group) }
  let(:project) { create(:project, group: group) }
  let(:user) { create(:user) }
  let(:full_path) { project.full_path }
  let(:profile_name) { SecureRandom.hex }
  let(:target_url) { generate(:url) }
  let(:dast_site_profile) { DastSiteProfile.find_by(project: project, name: profile_name) }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: full_path,
        profile_name: profile_name,
        target_url: target_url
      )
    end

    context 'when on demand scan feature is enabled' do
      context 'when the project does not exist' do
        let(:full_path) { SecureRandom.hex }

        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user is not associated with the project' do
        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user is an owner' do
        it 'returns the dast_site_profile id' do
          group.add_owner(user)

          expect(subject[:id]).to eq(dast_site_profile.to_global_id)
        end
      end

      context 'when the user is a maintainer' do
        it 'returns the dast_site_profile id' do
          project.add_maintainer(user)

          expect(subject[:id]).to eq(dast_site_profile.to_global_id)
        end
      end

      context 'when the user can run a dast scan' do
        before do
          project.add_developer(user)
        end

        it 'returns the dast_site_profile id' do
          expect(subject[:id]).to eq(dast_site_profile.to_global_id)
        end

        it 'calls the dast_site_profile creation service' do
          service = double(described_class)
          result = double('result', success?: false, errors: [])

          expect(DastSiteProfiles::CreateService).to receive(:new).and_return(service)
          expect(service).to receive(:execute).with(name: profile_name, target_url: target_url).and_return(result)

          subject
        end

        context 'when the project name already exists' do
          it 'returns an error' do
            subject

            response = mutation.resolve(
              full_path: full_path,
              profile_name: profile_name,
              target_url: target_url
            )

            expect(response[:errors]).to include('Name has already been taken')
          end
        end

        context 'when on demand scan licensed feature is not available' do
          it 'raises an exception' do
            stub_licensed_features(security_on_demand_scans: false)

            expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
          end
        end
      end
    end
  end
end
