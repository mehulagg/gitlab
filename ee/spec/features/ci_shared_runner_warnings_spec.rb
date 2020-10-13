# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CI shared runner limits' do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:user) { create(:user) }
  let(:project) { create(:project, :repository, namespace: group, shared_runners_enabled: true) }
  let(:group) { create(:group) }
  let(:pipeline) { create(:ci_empty_pipeline, project: project, sha: project.commit.sha, ref: 'master') }
  let!(:job) { create(:ci_build, pipeline: pipeline) }

  before do
    sign_in(user)
  end

  context 'when on a project related page' do
    before do
      group.add_developer(user)
    end

    where(:case_name, :percent, :remaining_minutes) do
      'warning level' | 30 | 4
      'danger level' | 5 | 1
    end

    with_them do
      context "when there is a notification and minutes still exist", :js do
        let(:message) do
          "Group #{group.name} has #{percent}% or less Shared Runner Pipeline minutes remaining. " \
            "Once it runs out, no new jobs or pipelines in its projects will run."
        end

        before do
          group.update!(shared_runners_minutes_limit: 20)
          allow_any_instance_of(EE::Namespace).to receive(:shared_runners_remaining_minutes).and_return(remaining_minutes)
        end

        it 'displays a warning message on pipelines page' do
          visit project_pipelines_path(project)

          expect_quota_exceeded_alert(message)
        end

        it 'displays a warning message on project homepage' do
          visit project_path(project)

          expect_quota_exceeded_alert(message)
        end

        it 'displays a warning message on a job page' do
          visit project_job_path(project, job)

          expect_quota_exceeded_alert(message)
        end
      end
    end

    context 'when limit is exceeded', :js do
      let(:group) { create(:group, :with_used_build_minutes_limit) }
      let(:message) do
        "Group #{group.name} has exceeded its pipeline minutes quota. " \
          "Unless you buy additional pipeline minutes, no new jobs or pipelines in its projects will run."
      end

      it 'displays a warning message on project homepage' do
        visit project_path(project)

        expect_quota_exceeded_alert(message)
      end

      it 'displays a warning message on pipelines page' do
        visit project_pipelines_path(project)

        expect_quota_exceeded_alert(message)
      end

      it 'displays a warning message on a job page' do
        visit project_job_path(project, job)

        expect_quota_exceeded_alert(message)
      end
    end

    context 'when limit not yet exceeded' do
      let(:group) { create(:group, :with_not_used_build_minutes_limit) }

      it 'does not display a warning message on project homepage' do
        visit project_path(project)

        expect_no_quota_exceeded_alert
      end

      it 'does not display a warning message on pipelines page' do
        visit project_pipelines_path(project)

        expect_no_quota_exceeded_alert
      end

      it 'displays a warning message on a job page' do
        visit project_job_path(project, job)

        expect_no_quota_exceeded_alert
      end
    end
  end

  context 'when on a group related page' do
    before do
      group.add_owner(user)
    end

    where(:case_name, :percent, :remaining_minutes) do
      'warning level' | 30 | 4
      'danger level' | 5 | 1
    end

    with_them do
      context "when there is a notification and minutes still exist", :js do
        let(:message) do
          "Group #{group.name} has #{percent}% or less Shared Runner Pipeline minutes remaining. " \
            "Once it runs out, no new jobs or pipelines in its projects will run."
        end

        before do
          group.update!(shared_runners_minutes_limit: 20)
          allow_any_instance_of(EE::Namespace).to receive(:shared_runners_remaining_minutes).and_return(remaining_minutes)
        end

        it 'displays a warning message on group overview page' do
          visit group_path(group)

          expect_quota_exceeded_alert(message)
        end
      end
    end

    context 'when limit is exceeded', :js do
      let(:group) { create(:group, :with_used_build_minutes_limit) }
      let(:message) do
        "Group #{group.name} has exceeded its pipeline minutes quota. " \
          "Unless you buy additional pipeline minutes, no new jobs or pipelines in its projects will run."
      end

      it 'displays a warning message on group overview page' do
        visit group_path(group)

        expect_quota_exceeded_alert(message)
      end
    end

    context 'when limit not yet exceeded' do
      let(:group) { create(:group, :with_not_used_build_minutes_limit) }

      it 'does not display a warning message on group overview page' do
        visit group_path(group)

        expect_no_quota_exceeded_alert
      end
    end
  end

  def expect_quota_exceeded_alert(message)
    expect(page).to have_selector('.shared-runner-quota-message', count: 1)

    page.within('.shared-runner-quota-message') do
      expect(page).to have_content(message)
      expect(page).to have_link 'Buy more Pipeline minutes'
    end
  end

  def expect_no_quota_exceeded_alert
    expect(page).not_to have_selector('.shared-runner-quota-message')
  end
end
