# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequirementsManagement::UpdateRequirementService do
  let_it_be(:title) { 'title' }
  let_it_be(:description) { 'description' }

  let(:new_title) { 'new title' }
  let(:new_description) { 'new description' }

  let_it_be(:project) { create(:project)}
  let_it_be(:user) { create(:user) }
  let_it_be_with_reload(:requirement) { create(:requirement, project: project, title: title, description: description) }

  let(:params) do
    {
      title: new_title,
      description: new_description,
      state: 'archived',
      created_at: 2.days.ago,
      author_id: create(:user).id
    }
  end

  subject { described_class.new(project, user, params).execute(requirement) }

  describe '#execute' do
    before do
      stub_licensed_features(requirements: true)
    end

    context 'when user can update requirements' do
      before do
        project.add_reporter(user)
      end

      it 'updates the requirement with only permitted params', :aggregate_failures do
        is_expected.to have_attributes(
          errors: be_empty,
          title: params[:title],
          state: params[:state]
        )
        is_expected.not_to have_attributes(
          created_at: params[:created_at],
          author_id: params[:author_id]
        )
      end

      context 'when updating title or description' do
        context 'if there is an associated requirement_issue' do
          let_it_be_with_reload(:requirement_issue) { create(:requirement_issue, requirement: requirement, title: title, description: description) }

          let(:params) do
            { title: new_title, description: new_description }
          end

          it 'updates the synced requirement_issue with title or description' do
            expect { subject }.to change { requirement.requirement_issue.description }.from(description).to(new_description)
          end

          context 'when updating only title' do
            let(:params) do
              { title: new_title }
            end

            it "updates requirement's title" do
              expect { subject }.to change { requirement.requirement_issue.reload.title }.from(title).to(new_title)
            end
          end

          context "updates requirement's description" do
            let(:params) do
              { description: new_description }
            end

            it 'updates description' do
              expect { subject }.to change { requirement.requirement_issue.reload.description }.from(description).to(new_description)
            end
          end

          context 'if update fails' do
            let(:params) do
              { title: nil }
            end

            it 'does not update' do
              expect { subject }.not_to change { requirement.reload.title }
              expect { subject }.not_to change { requirement.requirement_issue.reload.title }
            end
          end

          context 'when updating some unrelated field' do
            let(:params) do
              { state: :archived }
            end

            it 'does not update' do
              expect { subject }.not_to change { requirement.requirement_issue.state }
            end
          end
        end

        context 'if there is no requirement_issue' do
          it 'does not call the Issues::UpdateService' do
            expect(Issues::CreateService).not_to receive(:new)

            subject
          end
        end
      end

      context 'when updating last test report state' do
        context 'as passing' do
          it 'creates passing test report with null build_id' do
            service = described_class.new(project, user, { last_test_report_state: 'passed' })

            expect { service.execute(requirement) }.to change { RequirementsManagement::TestReport.count }.from(0).to(1)
            test_report = requirement.test_reports.last
            expect(requirement.last_test_report_state).to eq('passed')
            expect(requirement.last_test_report_manually_created?).to eq(true)
            expect(test_report.state).to eq('passed')
            expect(test_report.build).to eq(nil)
            expect(test_report.author).to eq(user)
          end
        end

        context 'as failed' do
          it 'creates failing test report with null build_id' do
            service = described_class.new(project, user, { last_test_report_state: 'failed' })

            expect { service.execute(requirement) }.to change { RequirementsManagement::TestReport.count }.from(0).to(1)
            test_report = requirement.test_reports.last
            expect(requirement.last_test_report_state).to eq('failed')
            expect(requirement.last_test_report_manually_created?).to eq(true)
            expect(test_report.state).to eq('failed')
            expect(test_report.build).to eq(nil)
            expect(test_report.author).to eq(user)
          end
        end

        context 'when user cannot create test reports' do
          it 'does not create test report' do
            allow(Ability).to receive(:allowed?).and_call_original
            allow(Ability).to receive(:allowed?).with(user, :create_requirement_test_report, project).and_return(false)
            service = described_class.new(project, user, { last_test_report_state: 'failed' })

            expect { service.execute(requirement) }.not_to change { RequirementsManagement::TestReport.count }
          end
        end
      end
    end

    context 'when user is not allowed to update requirements' do
      it 'raises an exception' do
        expect { subject }.to raise_exception(Gitlab::Access::AccessDeniedError)
      end
    end
  end
end
