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
            auth_password_field: dast_site_profile.auth_password_field,
            auth_username: dast_site_profile.auth_username,
            auth_username_field: dast_site_profile.auth_username_field,
            auth_url: dast_site_profile.auth_url,
            branch: project.default_branch,
            dast_profile: nil,
            excluded_urls: dast_site_profile.excluded_urls.join(','),
            target_url: dast_site_profile.dast_site.url
          )
        end
      end

      context 'when the dast_scanner_profile is provided' do
        let(:params) { { dast_site_profile: dast_site_profile, dast_scanner_profile: dast_scanner_profile } }

        it 'returns prepared scanner params in the payload' do
          expect(subject.payload).to eq(
            auth_password_field: dast_site_profile.auth_password_field,
            auth_username: dast_site_profile.auth_username,
            auth_username_field: dast_site_profile.auth_username_field,
            auth_url: dast_site_profile.auth_url,
            branch: project.default_branch,
            dast_profile: nil,
            excluded_urls: dast_site_profile.excluded_urls.join(','),
            full_scan_enabled: false,
            show_debug_messages: false,
            spider_timeout: nil,
            target_timeout: nil,
            target_url: dast_site_profile.dast_site.url,
            use_ajax_spider: false
          )
        end

        context 'when dast_site_profile.excluded_urls is empty' do
          let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project, excluded_urls: []) }

          it 'returns nil' do
            expect(subject.payload[:excluded_urls]).to be_nil
          end
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

      context 'when authentication is not enabled' do
        let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project, auth_enabled: false) }

        it 'returns prepared scanner params excluding auth params in the payload' do
          expect(subject.payload).to eq(
            branch: project.default_branch,
            dast_profile: nil,
            excluded_urls: dast_site_profile.excluded_urls.join(','),
            full_scan_enabled: false,
            show_debug_messages: false,
            spider_timeout: nil,
            target_timeout: nil,
            target_url: dast_site_profile.dast_site.url,
            use_ajax_spider: false
          )
        end
      end
    end

    context 'when the dast_profile is provided' do
      let_it_be(:dast_profile) { create(:dast_profile, project: project, dast_site_profile: dast_site_profile, dast_scanner_profile: dast_scanner_profile, branch_name: 'hello-world') }

      let(:params) { { dast_profile: dast_profile } }

      it 'returns prepared scanner params in the payload' do
        expect(subject.payload).to eq(
          auth_password_field: dast_site_profile.auth_password_field,
          auth_username: dast_site_profile.auth_username,
          auth_username_field: dast_site_profile.auth_username_field,
          branch: dast_profile.branch_name,
          auth_url: dast_site_profile.auth_url,
          dast_profile: dast_profile,
          excluded_urls: dast_site_profile.excluded_urls.join(','),
          full_scan_enabled: false,
          show_debug_messages: false,
          spider_timeout: nil,
          target_timeout: nil,
          target_url: dast_site_profile.dast_site.url,
          use_ajax_spider: false
        )
      end
    end
  end
end
