# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastOnDemandScans::ParamsCreateService do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

  let(:params) { { dast_site_profile: dast_site_profile, dast_scanner_profile: dast_scanner_profile } }

  subject { described_class.new(container: project, params: params).execute }

  describe 'execute' do
    context 'when the dast_site_profile is not provided' do
      let(:params) { { dast_site_profile: nil, dast_scanner_profile: dast_scanner_profile } }

      it 'responds with error message', :aggregate_failures do
        expect(subject).not_to be_success
        expect(subject.message).to eq('Dast site profile was not provided')
      end
    end

    context 'when the dast_site_profile is provided' do
      context 'when the branch is provided' do
        let(:params) { { dast_site_profile: dast_site_profile, branch: 'other-branch' } }

        context 'when the branch exists' do
          it 'includes the branch in the prepared params' do
            project.repository.create_branch(params[:branch])

            expect(subject.payload[:branch]).to eq(params[:branch])
          end
        end
      end

      context 'when the dast_scanner_profile is not provided' do
        let(:params) { { dast_site_profile: dast_site_profile, dast_scanner_profile: nil } }

        it 'returns prepared scanner params in the payload' do
          expect(subject.payload).to eq(
            branch: project.default_branch,
            target_url: dast_site_profile.dast_site.url,
            excluded_urls: dast_site_profile.excluded_urls.join(','),
            auth_username_field: dast_site_profile.auth_username_field,
            auth_password_field: dast_site_profile.auth_password_field,
            auth_username: dast_site_profile.auth_username
          )
        end
      end

      context 'when the dast_scanner_profile is provided' do
        let(:params) { { dast_site_profile: dast_site_profile, dast_scanner_profile: dast_scanner_profile } }

        it 'returns prepared scanner params in the payload' do
          expect(subject.payload).to eq(
            branch: project.default_branch,
            target_url: dast_site_profile.dast_site.url,
            excluded_urls: dast_site_profile.excluded_urls.join(','),
            auth_username_field: dast_site_profile.auth_username_field,
            auth_password_field: dast_site_profile.auth_password_field,
            auth_username: dast_site_profile.auth_username,
            full_scan_enabled: false,
            show_debug_messages: false,
            spider_timeout: nil,
            target_timeout: nil,
            use_ajax_spider: false
          )
        end

        context 'when the target is not validated and an active scan is requested' do
          let_it_be(:active_dast_scanner_profile) { create(:dast_scanner_profile, project: project, scan_type: 'active') }

          let(:params) { { dast_site_profile: dast_site_profile, dast_scanner_profile: active_dast_scanner_profile } }

          it 'responds with error message', :aggregate_failures do
            expect(subject).not_to be_success
            expect(subject.message).to eq('Cannot run active scan against unvalidated target')
          end
        end
      end
    end
  end
end
