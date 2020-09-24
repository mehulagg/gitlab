# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DastScannerProfiles::Update do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:full_path) { project.full_path }
  let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project, target_timeout: 200, spider_timeout: 5000) }

  let_it_be(:new_profile_name) { SecureRandom.hex }
  let_it_be(:new_target_timeout) { dast_scanner_profile.target_timeout + 1 }
  let_it_be(:new_spider_timeout) { dast_scanner_profile.spider_timeout + 1 }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: full_path,
        id: scanner_profile_id,
        profile_name: new_profile_name,
        target_timeout: new_target_timeout,
        spider_timeout: new_spider_timeout
      )
    end

    let(:scanner_profile_id) { dast_scanner_profile.to_global_id }

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

      context 'when user can not run a DAST scan' do
        it 'raises an exception' do
          project.add_guest(user)

          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user can run a DAST scan' do
        before do
          project.add_developer(user)
        end

        it 'updates the dast_scanner_profile' do
          dast_scanner_profile = subject[:id].find

          aggregate_failures do
            expect(dast_scanner_profile.name).to eq(new_profile_name)
            expect(dast_scanner_profile.target_timeout).to eq(new_target_timeout)
            expect(dast_scanner_profile.spider_timeout).to eq(new_spider_timeout)
          end
        end

        context 'when dast scanner profile does not exist' do
          let(:scanner_profile_id) { Gitlab::GlobalId.build(nil, model_name: 'DastScannerProfile', id: 'does_not_exist') }

          it 'raises an exception' do
            expect(subject[:errors]).to include('Scanner profile not found for given parameters')
          end
        end

        context 'when on demand scan feature is not enabled' do
          it 'raises an exception' do
            stub_feature_flags(security_on_demand_scans_feature_flag: false)

            expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
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
