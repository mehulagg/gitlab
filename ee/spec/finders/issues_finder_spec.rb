require 'spec_helper'

describe IssuesFinder do
  describe '#execute' do
    include_context 'IssuesFinder context'
    include_context 'IssuesFinder#execute context'

    context 'scope: all' do
      let(:scope) { 'all' }

      describe 'filter by weight' do
        set(:issue_with_weight_1) { create(:issue, project: project3, weight: 1) }
        set(:issue_with_weight_42) { create(:issue, project: project3, weight: 42) }

        context 'filter issues with no weight' do
          let(:params) { { weight: Issue::WEIGHT_NONE } }

          it 'returns all issues' do
            expect(issues).to contain_exactly(issue1, issue2, issue3, issue4)
          end
        end

        context 'filter issues with any weight' do
          let(:params) { { weight: Issue::WEIGHT_ANY } }

          it 'returns all issues' do
            expect(issues).to contain_exactly(issue_with_weight_1, issue_with_weight_42)
          end
        end

        context 'filter issues with a specific weight' do
          let(:params) { { weight: 42 } }

          it 'returns all issues' do
            expect(issues).to contain_exactly(issue_with_weight_42)
          end
        end
      end

      context 'filtering by assignee IDs' do
        set(:user3) { create(:user) }
        let(:params) { { assignee_ids: [user2.id, user3.id] } }

        before do
          project2.add_developer(user3)

          issue3.assignees = [user2, user3]
        end

        it 'returns issues assigned to those users' do
          expect(issues).to contain_exactly(issue3)
        end
      end
    end
  end

  describe '#with_confidentiality_access_check' do
    let(:guest) { create(:user) }
    set(:authorized_user) { create(:user) }
    set(:project) { create(:project, namespace: authorized_user.namespace) }
    set(:public_issue) { create(:issue, project: project) }
    set(:confidential_issue) { create(:issue, project: project, confidential: true) }

    context 'when no project filter is given' do
      let(:params) { {} }

      context 'for an auditor' do
        let(:auditor_user) { create(:user, :auditor) }

        subject { described_class.new(auditor_user, params).with_confidentiality_access_check }

        it 'returns all issues' do
          expect(subject).to include(public_issue, confidential_issue)
        end
      end
    end

    context 'when searching within a specific project' do
      let(:params) { { project_id: project.id } }

      context 'for an auditor' do
        let(:auditor_user) { create(:user, :auditor) }

        subject { described_class.new(auditor_user, params).with_confidentiality_access_check }

        it 'returns all issues' do
          expect(subject).to include(public_issue, confidential_issue)
        end
      end
    end
  end
end
