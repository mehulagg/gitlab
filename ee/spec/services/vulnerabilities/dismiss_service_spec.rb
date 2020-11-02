# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::DismissService do
  include AccessMatchersGeneric

  before do
    stub_licensed_features(security_dashboard: true)
  end

  let_it_be(:user) { create(:user) }
  let(:project) { create(:project) } # cannot use let_it_be here: caching causes problems with permission-related tests
  let!(:pipeline) { create(:ci_pipeline, :success, project: project) }
  let!(:build) { create(:ee_ci_build, :sast, pipeline: pipeline) }
  let(:vulnerability) { create(:vulnerability, :with_findings, project: project) }
  let(:service) { described_class.new(user, vulnerability) }

  subject(:dismiss_vulnerability) { service.execute }

  context 'with an authorized user with proper permissions' do
    before do
      project.add_developer(user)
    end

    it_behaves_like 'calls vulnerability statistics utility services in order'

    it 'dismisses a vulnerability and its associated findings' do
      Timecop.freeze do
        dismiss_vulnerability

        expect(vulnerability.reload).to(
          have_attributes(state: 'dismissed', dismissed_by: user, dismissed_at: be_like_time(Time.current)))
        expect(vulnerability.findings).to all have_vulnerability_dismissal_feedback
      end
    end

    context 'when comment is added' do
      let(:comment) { 'Dismissal Comment' }
      let(:service) { described_class.new(user, vulnerability, comment) }

      it 'dismisses a vulnerability and its associated findings with comment', :aggregate_failures do
        Timecop.freeze do
          dismiss_vulnerability

          aggregate_failures do
            expect(vulnerability.reload).to(
              have_attributes(state: 'dismissed', dismissed_by: user, dismissed_at: be_like_time(Time.current)))
            expect(vulnerability.findings).to all have_vulnerability_dismissal_feedback
            expect(vulnerability.findings.map(&:dismissal_feedback)).to(
              all(have_attributes(comment: comment, comment_author: user, comment_timestamp: be_like_time(Time.current), pipeline_id: pipeline.id)))
          end
        end
      end
    end

    it 'creates note' do
      expect(SystemNoteService).to receive(:change_vulnerability_state).with(vulnerability, user)

      dismiss_vulnerability
    end

    context 'when there is a finding dismissal error' do
      before do
        allow(service).to receive(:dismiss_findings).and_return(
          described_class::FindingsDismissResult.new(false, broken_finding, 'something went wrong'))
      end

      let(:broken_finding) { vulnerability.findings.first }

      it 'responds with error' do
        expect(dismiss_vulnerability.errors.messages).to eq(
          base: ["failed to dismiss associated finding(id=#{broken_finding.id}): something went wrong"])
      end
    end

    context 'when security dashboard feature is disabled' do
      before do
        stub_licensed_features(security_dashboard: false)
      end

      it 'raises an "access denied" error' do
        expect { dismiss_vulnerability }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end
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
