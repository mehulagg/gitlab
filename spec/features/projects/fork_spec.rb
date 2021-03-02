# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project fork' do
  include ProjectForksHelper

  let(:user) { create(:user) }
  let(:project) { create(:project, :public, :repository) }

  before do
    sign_in(user)
  end

  it 'allows user to fork project from the project page' do
    visit project_path(project)

    expect(page).not_to have_css('a.disabled', text: 'Fork')
  end

  context 'user has exceeded personal project limit' do
    before do
      user.update!(projects_limit: 0)
    end

    it 'disables fork button on project page' do
      visit project_path(project)

      expect(page).to have_css('a.disabled', text: 'Fork')
    end

    context 'with a group to fork to' do
      let!(:group) { create(:group).tap { |group| group.add_owner(user) } }

      it 'enables fork button on project page' do
        visit project_path(project)

        expect(page).not_to have_css('a.disabled', text: 'Fork')
      end
    end
  end

  context 'forking enabled / disabled in project settings' do
    before do
      project.project_feature.update_attribute(
        :forking_access_level, forking_access_level)
    end

    context 'forking is enabled' do
      let(:forking_access_level) { ProjectFeature::ENABLED }

      it 'enables fork button' do
        visit project_path(project)

        expect(page).to have_css('a', text: 'Fork')
        expect(page).not_to have_css('a.disabled', text: 'Select')
      end

      it 'renders new project fork page' do
        visit new_project_fork_path(project)

        expect(page.status_code).to eq(200)
        expect(page).to have_text('Fork project')
      end
    end

    context 'forking is disabled' do
      let(:forking_access_level) { ProjectFeature::DISABLED }

      it 'does not render fork button' do
        visit project_path(project)

        expect(page).not_to have_css('a', text: 'Fork')
      end

      it 'does not render new project fork page' do
        visit new_project_fork_path(project)

        expect(page.status_code).to eq(404)
      end
    end

    context 'forking is private' do
      let(:forking_access_level) { ProjectFeature::PRIVATE }

      before do
        project.update(visibility_level: Gitlab::VisibilityLevel::INTERNAL)
      end

      context 'user is not a team member' do
        it 'does not render fork button' do
          visit project_path(project)

          expect(page).not_to have_css('a', text: 'Fork')
        end

        it 'does not render new project fork page' do
          visit new_project_fork_path(project)

          expect(page.status_code).to eq(404)
        end
      end

      context 'user is a team member' do
        before do
          project.add_developer(user)
        end

        it 'enables fork button' do
          visit project_path(project)

          expect(page).to have_css('a', text: 'Fork')
          expect(page).not_to have_css('a.disabled', text: 'Fork')
        end
        # FAIL
        it 'renders new project fork page' do
          visit new_project_fork_path(project)

          expect(page.status_code).to eq(200)
          expect(page).to have_text('Fork project')
        end
      end
    end
  end

  # Tests to be added:

  # When the project is already forked
  # Issue: https://gitlab.com/gitlab-org/gitlab/-/issues/323148
  # Issue: https://gitlab.com/gitlab-org/gitlab/-/issues/323146

  # Forking options when the user is a maintainer and in a group
  # Issue: https://gitlab.com/gitlab-org/gitlab/-/issues/323147
end
