# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    describe 'prevent forking outside group' do
      let!(:group_for_fork) do
        Resource::Sandbox.fabricate_via_api! do |sandbox_group|
          sandbox_group.path = "group_for_fork_#{SecureRandom.hex(8)}"
        end
      end

      let(:project) do
        Resource::Project.fabricate! do |project|
          project.name = "project_to_fork"
          project.initialize_with_readme = true
        end
      end

      context 'when disabled' do
        before do
          Flow::Login.sign_in
          project.group.sandbox.visit!
          Page::Group::Menu.perform(&:click_group_general_settings_item)
          Page::Group::Settings::General.perform(&:set_prevent_forking_outside_group_disabled)
        end

        it 'allows forking outside of group' do
          project.visit!
          Page::Project::Show.perform(&:fork_project)

          Page::Project::Fork::New.perform do |fork_new|
            fork_new.search_for_group(group_for_fork.path)
          end

          expect(page).to have_text(group_for_fork.path)
          expect(page).to have_text('Select a namespace to fork the project')
        end
      end

      context 'when enabled' do
        before do
          Flow::Login.sign_in
          project.group.sandbox.visit!
          Page::Group::Menu.perform(&:click_group_general_settings_item)
          Page::Group::Settings::General.perform(&:set_prevent_forking_outside_group_enabled)
        end

        it 'does not allow forking outside of group' do
          project.visit!
          Page::Project::Show.perform(&:fork_project)

          Page::Project::Fork::New.perform do |fork_new|
            fork_new.search_for_group(group_for_fork.path)
          end

          expect(page).not_to have_text(group_for_fork.path)
          expect(page).not_to have_text('Select a namespace to fork the project')
        end
      end

      after do
        project.group.sandbox.update_group_setting(group_setting: 'prevent_forking_outside_group', value: false)
        project.remove_via_api!
        group_for_fork.remove_via_api!
      end
    end
  end
end
