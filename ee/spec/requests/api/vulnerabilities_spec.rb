# frozen_string_literal: true

require 'spec_helper'

describe API::Vulnerabilities do
  include AccessMatchersForRequest

  before do
    stub_licensed_features(security_dashboard: true)
  end

  let_it_be(:user) { create(:user) }
  let(:project_vulnerabilities_path) { "/projects/#{project.id}/vulnerabilities" }

  shared_examples 'forbids actions on vulnerability in case of disabled features' do
    context 'when "first-class vulnerabilities" feature is disabled' do
      before do
        stub_feature_flags(first_class_vulnerabilities: false)
      end

      it 'responds with "not found"' do
        subject

        expect(response).to have_gitlab_http_status(404)
      end
    end

    context 'when security dashboard feature is not available' do
      before do
        stub_licensed_features(security_dashboard: false)
      end

      it 'responds with 403 Forbidden' do
        subject

        expect(response).to have_gitlab_http_status(403)
      end
    end
  end

  describe 'GET /projects/:id/vulnerabilities' do
    let_it_be(:project) { create(:project, :with_vulnerabilities) }

    subject(:get_vulnerabilities) { get api(project_vulnerabilities_path, user) }

    context 'with an authorized user with proper permissions' do
      before do
        project.add_developer(user)
      end

      it 'returns all vulnerabilities of a project' do
        get_vulnerabilities

        expect(response).to have_gitlab_http_status(200)
        expect(response).to include_pagination_headers
        expect(response).to match_response_schema('public_api/v4/vulnerabilities', dir: 'ee')
        expect(response.headers['X-Total']).to eq project.vulnerabilities.count.to_s
      end

      context 'with pagination' do
        let(:project_vulnerabilities_path) { "#{super()}?page=2&per_page=1" }

        it 'paginates the vulnerabilities according to the pagination params' do
          get_vulnerabilities

          expect(response).to have_gitlab_http_status(200)
          expect(json_response.map { |v| v['id'] }).to contain_exactly(project.vulnerabilities.second.id)
        end
      end

      it_behaves_like 'forbids actions on vulnerability in case of disabled features'
    end

    describe 'permissions' do
      it { expect { get_vulnerabilities }.to be_allowed_for(:admin) }
      it { expect { get_vulnerabilities }.to be_allowed_for(:owner).of(project) }
      it { expect { get_vulnerabilities }.to be_allowed_for(:maintainer).of(project) }
      it { expect { get_vulnerabilities }.to be_allowed_for(:developer).of(project) }
      it { expect { get_vulnerabilities }.to be_allowed_for(:auditor) }

      it { expect { get_vulnerabilities }.to be_denied_for(:reporter).of(project) }
      it { expect { get_vulnerabilities }.to be_denied_for(:guest).of(project) }
      it { expect { get_vulnerabilities }.to be_denied_for(:anonymous) }
    end
  end

  describe 'POST /projects/:id/vulnerabilities' do
    let_it_be(:project) { create(:project) }
    let(:finding) { create(:vulnerabilities_occurrence, project: project) }
    let(:finding_id) { finding.id }
    let(:expected_error_messages) { { 'base' => ['finding is not found or is already attached to a vulnerability'] } }

    subject(:create_vulnerability) { post api(project_vulnerabilities_path, user), params: { finding_id: finding_id } }

    context 'with an authorized user with proper permissions' do
      before do
        project.add_developer(user)
      end

      it 'creates a vulnerability from finding and attaches it to the vulnerability' do
        expect { subject }.to change { project.vulnerabilities.count }.by(1)
        expect(project.vulnerabilities.last).to(
          have_attributes(
            author: user,
            title: finding.name,
            state: 'opened',
            severity: finding.severity,
            severity_overridden: false,
            confidence: finding.confidence,
            confidence_overridden: false,
            report_type: finding.report_type
          ))

        expect(response).to have_gitlab_http_status(201)
        expect(response).to match_response_schema('public_api/v4/vulnerability', dir: 'ee')
      end

      context 'when finding id is unknown' do
        let(:finding_id) { 0 }

        it 'responds with expected error' do
          subject

          expect(response).to have_gitlab_http_status(400)
          expect(json_response['message']).to eq(expected_error_messages)
        end
      end

      context 'when a vulnerability already exists for a specific finding' do
        before do
          create(:vulnerability, findings: [finding], project: finding.project)
        end

        it 'rejects creation of a new vulnerability from this finding' do
          subject

          expect(response).to have_gitlab_http_status(400)
          expect(json_response['message']).to eq(expected_error_messages)
        end
      end

      it_behaves_like 'forbids actions on vulnerability in case of disabled features'
    end

    describe 'permissions' do
      it { expect { create_vulnerability }.to be_allowed_for(:admin) }
      it { expect { create_vulnerability }.to be_allowed_for(:owner).of(project) }
      it { expect { create_vulnerability }.to be_allowed_for(:maintainer).of(project) }
      it { expect { create_vulnerability }.to be_allowed_for(:developer).of(project) }

      it { expect { create_vulnerability }.to be_denied_for(:auditor) }
      it { expect { create_vulnerability }.to be_denied_for(:reporter).of(project) }
      it { expect { create_vulnerability }.to be_denied_for(:guest).of(project) }
      it { expect { create_vulnerability }.to be_denied_for(:anonymous) }
    end
  end

  describe 'POST /vulnerabilities:id/dismiss' do
    before do
      create_list(:vulnerabilities_occurrence, 2, vulnerability: vulnerability, project: vulnerability.project)
    end

    let_it_be(:project) { create(:project, :with_vulnerabilities) }
    let(:vulnerability) { project.vulnerabilities.first }

    subject(:dismiss_vulnerability) { post api("/vulnerabilities/#{vulnerability.id}/dismiss", user) }

    context 'with an authorized user with proper permissions' do
      before do
        project.add_developer(user)
      end

      it 'dismisses a vulnerability and its associated findings' do
        Timecop.freeze do
          dismiss_vulnerability

          expect(response).to have_gitlab_http_status(201)
          expect(response).to match_response_schema('public_api/v4/vulnerability', dir: 'ee')

          expect(vulnerability.reload).to(
            have_attributes(state: 'closed', closed_by: user, closed_at: be_like_time(Time.current)))
          expect(vulnerability.findings).to all have_vulnerability_dismissal_feedback
        end
      end

      context 'when there is a dismissal error' do
        before do
          Grape::Endpoint.before_each do |endpoint|
            allow(endpoint).to receive(:find_vulnerability!).and_wrap_original do |method, *args|
              vulnerability = method.call(*args)

              errors = ActiveModel::Errors.new(vulnerability)
              errors.add(:base, 'something went wrong')

              allow(vulnerability).to receive(:valid?).and_return(false)
              allow(vulnerability).to receive(:errors).and_return(errors)

              vulnerability
            end
          end
        end

        after do
          # resetting according to the https://github.com/ruby-grape/grape#stubbing-helpers
          Grape::Endpoint.before_each nil
        end

        it 'responds with error' do
          dismiss_vulnerability

          expect(response).to have_gitlab_http_status(400)
          expect(json_response['message']).to eq('base' => ['something went wrong'])
        end
      end

      context 'if a vulnerability is already dismissed' do
        let(:vulnerability) { create(:vulnerability, :closed, project: project) }

        it 'responds with 304 Not Modified' do
          dismiss_vulnerability

          expect(response).to have_gitlab_http_status(304)
        end
      end

      it_behaves_like 'forbids actions on vulnerability in case of disabled features'
    end

    describe 'permissions' do
      it { expect { dismiss_vulnerability }.to be_allowed_for(:admin) }
      it { expect { dismiss_vulnerability }.to be_allowed_for(:owner).of(project) }
      it { expect { dismiss_vulnerability }.to be_allowed_for(:maintainer).of(project) }
      it { expect { dismiss_vulnerability }.to be_allowed_for(:developer).of(project) }

      it { expect { dismiss_vulnerability }.to be_denied_for(:auditor) }
      it { expect { dismiss_vulnerability }.to be_denied_for(:reporter).of(project) }
      it { expect { dismiss_vulnerability }.to be_denied_for(:guest).of(project) }
      it { expect { dismiss_vulnerability }.to be_denied_for(:anonymous) }
    end
  end

  describe 'POST /vulnerabilities:id/resolve' do
    before do
      create_list(:vulnerabilities_finding, 2, vulnerability: vulnerability)
    end

    let_it_be(:project) { create(:project, :with_vulnerabilities) }
    let(:vulnerability) { project.vulnerabilities.first }

    subject(:resolve_vulnerability) { post api("/vulnerabilities/#{vulnerability.id}/resolve", user) }

    context 'with an authorized user with proper permissions' do
      before do
        project.add_developer(user)
      end

      it 'resolves a vulnerability and its associated findings' do
        Timecop.freeze do
          resolve_vulnerability

          expect(response).to have_gitlab_http_status(201)
          expect(response).to match_response_schema('public_api/v4/vulnerability', dir: 'ee')

          expect(vulnerability.reload).to(
            have_attributes(state: 'resolved', resolved_by: user, resolved_at: be_like_time(Time.current)))
          expect(vulnerability.findings).to all have_attributes(state: 'resolved')
        end
      end

      context 'when the vulnerability is already resolved' do
        let(:vulnerability) { create(:vulnerability, :resolved, project: project) }

        it 'responds with 304 Not Modified response' do
          resolve_vulnerability

          expect(response).to have_gitlab_http_status(304)
        end
      end

      it_behaves_like 'forbids actions on vulnerability in case of disabled features'
    end

    describe 'permissions' do
      it { expect { resolve_vulnerability }.to be_allowed_for(:admin) }
      it { expect { resolve_vulnerability }.to be_allowed_for(:owner).of(project) }
      it { expect { resolve_vulnerability }.to be_allowed_for(:maintainer).of(project) }
      it { expect { resolve_vulnerability }.to be_allowed_for(:developer).of(project) }

      it { expect { resolve_vulnerability }.to be_denied_for(:auditor) }
      it { expect { resolve_vulnerability }.to be_denied_for(:reporter).of(project) }
      it { expect { resolve_vulnerability }.to be_denied_for(:guest).of(project) }
      it { expect { resolve_vulnerability }.to be_denied_for(:anonymous) }
    end
  end
end
