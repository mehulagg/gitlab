# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AppSec::Dast::ScanConfigs::CreateService do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:dast_profile) { create(:dast_profile, project: project, branch_name: 'master') }
  let_it_be(:dast_site_profile) { dast_profile.dast_site_profile }
  let_it_be(:dast_scanner_profile) { dast_profile.dast_scanner_profile }

  let(:dast_website) { dast_site_profile.dast_site.url }
  let(:dast_username) { dast_site_profile.auth_username }

  let(:params) { { dast_site_profile: dast_site_profile, dast_scanner_profile: dast_scanner_profile } }

  subject { described_class.new(container: project, params: params).execute }

  describe 'execute' do
    context 'when a dast_profile is provided' do
      let(:params) { { dast_profile: dast_profile } }

      let(:expected_yaml_configuration) do
        <<~YAML
            ---
            stages:
            - dast
            include:
            - template: DAST-On-Demand-Scan.gitlab-ci.yml
            variables:
              DAST_WEBSITE: #{dast_website}
              DAST_EXCLUDE_URLS: #{dast_website}/sign-out,#{dast_website}/hidden
              DAST_AUTH_URL: #{dast_website}/sign-in
              DAST_USERNAME: #{dast_username}
              DAST_USERNAME_FIELD: session[username]
              DAST_PASSWORD_FIELD: session[password]
              DAST_FULL_SCAN_ENABLED: 'false'
              DAST_USE_AJAX_SPIDER: 'false'
              DAST_DEBUG: 'false'
        YAML
      end

      it 'returns a dast_profile, dast_site_profile, dast_scanner_profile, branch and YAML configuration' do
        expected_payload = {
          dast_profile: dast_profile,
          dast_site_profile: dast_site_profile,
          dast_scanner_profile: dast_scanner_profile,
          branch: dast_profile.branch_name,
          ci_configuration: expected_yaml_configuration
        }

        expect(subject.payload).to eq(expected_payload)
      end
    end

    context 'when a dast_site_profile is provided' do
      context 'when a dast_scanner_profile is not provided' do
        let(:params) { { dast_site_profile: dast_site_profile } }

        let(:expected_yaml_configuration) do
          <<~YAML
            ---
            stages:
            - dast
            include:
            - template: DAST-On-Demand-Scan.gitlab-ci.yml
            variables:
              DAST_WEBSITE: #{dast_website}
              DAST_EXCLUDE_URLS: #{dast_website}/sign-out,#{dast_website}/hidden
              DAST_AUTH_URL: #{dast_website}/sign-in
              DAST_USERNAME: #{dast_username}
              DAST_USERNAME_FIELD: session[username]
              DAST_PASSWORD_FIELD: session[password]
          YAML
        end

        it 'returns a dast_site_profile, branch and YAML configuration' do
          expected_payload = {
            dast_profile: nil,
            dast_site_profile: dast_site_profile,
            dast_scanner_profile: nil,
            branch: project.default_branch,
            ci_configuration: expected_yaml_configuration
          }

          expect(subject.payload).to eq(expected_payload)
        end
      end

      context 'when a dast_scanner_profile is provided' do
        let(:params) { { dast_site_profile: dast_site_profile, dast_scanner_profile: dast_scanner_profile } }

        let(:expected_yaml_configuration) do
          <<~YAML
            ---
            stages:
            - dast
            include:
            - template: DAST-On-Demand-Scan.gitlab-ci.yml
            variables:
              DAST_WEBSITE: #{dast_website}
              DAST_EXCLUDE_URLS: #{dast_website}/sign-out,#{dast_website}/hidden
              DAST_AUTH_URL: #{dast_website}/sign-in
              DAST_USERNAME: #{dast_username}
              DAST_USERNAME_FIELD: session[username]
              DAST_PASSWORD_FIELD: session[password]
              DAST_FULL_SCAN_ENABLED: 'false'
              DAST_USE_AJAX_SPIDER: 'false'
              DAST_DEBUG: 'false'
          YAML
        end

        it 'returns a dast_site_profile, dast_scanner_profile, branch and YAML configuration' do
          expected_payload = {
            dast_profile: nil,
            dast_site_profile: dast_site_profile,
            dast_scanner_profile: dast_scanner_profile,
            branch: project.default_branch,
            ci_configuration: expected_yaml_configuration
          }

          expect(subject.payload).to eq(expected_payload)
        end

        context 'when the target is not validated and an active scan is requested' do
          let_it_be(:active_dast_scanner_profile) { create(:dast_scanner_profile, project: project, scan_type: 'active') }

          let(:params) { { dast_site_profile: dast_site_profile, dast_scanner_profile: active_dast_scanner_profile } }

          it 'responds with an error message', :aggregate_failures do
            expect(subject).not_to be_success
            expect(subject.message).to eq('Cannot run active scan against unvalidated target')
          end
        end
      end
    end

    context 'when a dast_site_profile is not provided' do
      let(:params) { { dast_site_profile: nil, dast_scanner_profile: dast_scanner_profile } }

      it 'responds with an error message', :aggregate_failures do
        expect(subject).not_to be_success
        expect(subject.message).to eq('Dast site profile was not provided')
      end
    end

    context 'when a branch is provided' do
      let(:params) { { dast_site_profile: dast_site_profile, dast_scanner_profile: dast_scanner_profile, branch: 'hello-world' } }

      it 'returns the branch in the payload' do
        expect(subject.payload[:branch]).to match('hello-world')
      end
    end
  end
end
