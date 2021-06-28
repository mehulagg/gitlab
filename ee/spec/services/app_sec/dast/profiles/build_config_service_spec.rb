# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AppSec::Dast::Profiles::BuildConfigService do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }
  let_it_be(:user) { create(:user, developer_projects: [project] ) }

  let(:dast_site_profile_name) { dast_site_profile.name }
  let(:dast_scanner_profile_name) { dast_scanner_profile.name }

  let(:params) { { dast_site_profile: dast_site_profile_name, dast_scanner_profile: dast_scanner_profile_name } }

  subject { described_class.new(project: project, current_user: user, params: params).execute }

  describe '#execute' do
    before do
      stub_licensed_features(security_on_demand_scans: true)
    end

    shared_examples 'a fetch operation' do |dast_profile_name_key|
      context 'when licensed' do
        context 'when the profile exists' do
          it 'includes the profile in the payload', :aggregate_failures do
            expect(subject).to be_success
            expect(subject.payload[profile.class.underscore.to_sym]).to eq(profile)
          end
        end

        context 'when the profile is not provided' do
          let(dast_profile_name_key) { nil }

          it 'does not include the profile in the payload', :aggregate_failures do
            expect(subject).to be_success
            expect(subject.payload[profile.class.underscore.to_sym]).to be_nil
          end
        end

        context 'when the profile does not exist' do
          let(dast_profile_name_key) { SecureRandom.hex }

          it 'does not include the profile in the payload', :aggregate_failures do
            expect(subject).to be_success
            expect(subject.payload[profile.class.underscore.to_sym]).to be_nil
          end
        end

        context 'when the user does not have access to the profile' do
          let_it_be(:user) { build(:user) }

          it 'does not include the profile in the payload', :aggregate_failures do
            expect(subject).to be_success
            expect(subject.payload[profile.class.underscore.to_sym]).to be_nil
          end
        end
      end

      context 'when not licensed' do
        before do
          stub_licensed_features(security_on_demand_scans: false)
        end

        it 'communicates failure' do
          expect(subject).to have_attributes(status: :error, message: 'Insufficient permissions')
        end
      end
    end

    it_behaves_like 'a fetch operation', :dast_site_profile_name do
      let(:profile) { dast_site_profile }
    end

    it_behaves_like 'a fetch operation', :dast_scanner_profile_name do
      let(:profile) { dast_scanner_profile }
    end

    it 'includes all profiles in the payload' do
      expect(subject.payload).to eq(dast_site_profile: dast_site_profile, dast_scanner_profile: dast_scanner_profile)
    end
  end
end
