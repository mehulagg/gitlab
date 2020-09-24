# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FeedbackEntity do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let(:request) { double('request') }
  let(:entity) { described_class.represent(feedback, request: request) }

  subject { entity.as_json }

  before do
    allow(request).to receive(:current_user).and_return(user)
  end

  describe '#as_json' do
    let(:feedback) { build(:vulnerability_feedback, :issue, project: project) }

    it { is_expected.to include(:created_at, :project_id, :author, :category, :feedback_type) }

    context 'feedback type is issue' do
      let(:feedback) { build(:vulnerability_feedback, :issue, project: project) }

      context 'when issue is present' do
        it 'exposes the issue iid' do
          is_expected.to include(:issue_iid)
        end

        context 'when user can view issues' do
          before do
            project.add_developer(user)
          end

          it 'exposes issue url' do
            is_expected.to include(:issue_url)
          end
        end

        context 'when user cannot view issues' do
          it 'does not expose issue url' do
            is_expected.not_to include(:issue_url)
          end
        end
      end

      context 'when there is no current user' do
        let(:entity) { described_class.represent(feedback, request: request) }

        before do
          allow(request).to receive(:current_user).and_return(nil)
          allow(feedback).to receive(:author).and_return(nil)
        end

        subject { entity.as_json }

        it 'does not include fields related to current user' do
          is_expected.not_to include(:issue_url)
          is_expected.not_to include(:destroy_vulnerability_feedback_dismissal_path)
          is_expected.not_to include(:merge_request_path)
        end
      end

      context 'when issue is not present' do
        let(:feedback) { build(:vulnerability_feedback, feedback_type: :issue, project: project, issue: nil) }

        it 'does not expose issue information' do
          is_expected.not_to include(:issue_iid)
          is_expected.not_to include(:issue_url)
        end
      end

      context 'when allowed to destroy vulnerability feedback' do
        before do
          project.add_developer(user)
        end

        it 'does not contain destroy vulnerability feedback dismissal path' do
          expect(subject).not_to include(:destroy_vulnerability_feedback_dismissal_path)
        end
      end
    end

    context 'feedback type is merge_request' do
      let(:feedback) { build(:vulnerability_feedback, :merge_request, project: project) }

      context 'when merge request is present' do
        it 'exposes the merge request iid' do
          is_expected.to include(:merge_request_iid)
        end

        context 'when user can view merge requests' do
          before do
            project.add_developer(user)
          end

          it 'exposes merge request url' do
            is_expected.to include(:merge_request_path)
          end
        end

        context 'when user cannot view merge requests' do
          it 'does not expose merge request url' do
            is_expected.not_to include(:merge_request_path)
          end
        end
      end

      context 'when merge request is not present' do
        let(:feedback) { build(:vulnerability_feedback, :merge_request, project: project, merge_request: nil) }

        it 'does not expose merge request information' do
          is_expected.not_to include(:merge_request_iid)
          is_expected.not_to include(:merge_request_path)
        end
      end

      context 'when allowed to destroy vulnerability feedback' do
        before do
          project.add_developer(user)
        end

        it 'does not contain destroy vulnerability feedback dismissal path' do
          expect(subject).not_to include(:destroy_vulnerability_feedback_dismissal_path)
        end
      end
    end

    context 'feedback type is dismissal' do
      let(:feedback) { create(:vulnerability_feedback, :dismissal, project: project) }

      context 'when not allowed to destroy vulnerability feedback' do
        before do
          project.add_guest(user)
        end

        it 'does not contain destroy vulnerability feedback dismissal path' do
          expect(subject).not_to include(:destroy_vulnerability_feedback_dismissal_path)
        end
      end

      context 'when allowed to destroy vulnerability feedback' do
        before do
          project.add_developer(user)
        end

        it 'contains destroy vulnerability feedback dismissal path' do
          expect(subject).to include(:destroy_vulnerability_feedback_dismissal_path)
        end
      end
    end
  end

  context 'when comment is not present' do
    let(:feedback) { build(:vulnerability_feedback, :dismissal, project: project) }

    it { is_expected.not_to include(:comment_details) }
  end

  context 'when comment is present' do
    let(:feedback) { build(:vulnerability_feedback, :comment, project: project) }

    it 'exposes comment information' do
      expect(subject).to include(:comment_details)
      expect(subject[:comment_details]).to include(:comment)
      expect(subject[:comment_details]).to include(:comment_timestamp)
      expect(subject[:comment_details]).to include(:comment_author)
    end
  end
end
