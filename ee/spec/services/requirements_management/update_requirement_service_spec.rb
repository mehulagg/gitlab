# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequirementsManagement::UpdateRequirementService do
  let_it_be(:project) { create(:project)}
  let_it_be(:user) { create(:user) }
  let_it_be(:requirement) { create(:requirement, project: project) }

  let(:params) do
    {
      title: 'foo',
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
