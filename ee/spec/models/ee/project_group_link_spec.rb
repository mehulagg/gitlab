# frozen_string_literal: true

require 'spec_helper'

describe ProjectGroupLink do
  describe '#destroy' do
    let(:project) { create(:project) }
    let(:group) { create(:group) }
    let(:user) { create(:user) }
    let!(:project_group_link) { create(:project_group_link, project: project, group: group) }

    before do
      project.add_developer(user)
    end

    shared_examples_for 'deleted related access levels' do |access_level_class|
      it "removes related #{access_level_class}" do
        expect { project_group_link.destroy! }.to change(access_level_class, :count).by(-1)
        expect(access_levels.find_by_group_id(group)).to be_nil
        expect(access_levels.find_by_user_id(user)).to be_persisted
      end
    end

    context 'protected tags' do
      let!(:protected_tag) do
        ProtectedTags::CreateService.new(
          project,
          project.owner,
          attributes_for(
            :protected_tag,
            create_access_levels_attributes: [{ group_id: group.id }, { user_id: user.id }]
          )
        ).execute
      end

      let(:access_levels) { protected_tag.create_access_levels }

      it_behaves_like 'deleted related access levels', ProtectedTag::CreateAccessLevel
    end

    context 'protected environments' do
      let!(:protected_environment) do
        ProtectedEnvironments::CreateService.new(
          project,
          project.owner,
          attributes_for(
            :protected_environment,
            deploy_access_levels_attributes: [{ group_id: group.id }, { user_id: user.id }]
          )
        ).execute
      end

      let(:access_levels) { protected_environment.deploy_access_levels }

      it_behaves_like 'deleted related access levels', ProtectedEnvironment::DeployAccessLevel
    end
  end

  describe 'Updating max seats counter for GitLab subscription' do
    let(:project) { create(:project, namespace: create(:group)) }
    let!(:gitlab_subscription) { create(:gitlab_subscription, namespace: project.namespace) }
    let(:invited_group_1) { create(:group) }
    let(:invited_group_2) { create(:group) }

    before do
      create(:group_member, :developer, group: invited_group_1)
      create(:group_member, :developer, group: invited_group_2)

      allow(Gitlab::CurrentSettings.current_application_settings)
        .to receive(:should_check_namespace_plan?).and_return(true)
    end

    context 'on create' do
      it 'updates the max_seats_used counter' do
        expect { create_project_group_links }
          .to change { gitlab_subscription.reload.max_seats_used }.from(0).to(2)
      end
    end

    context 'on update' do
      it 'updates the max_seats_used counter' do
        create_project_group_links

        gitlab_subscription.update_attribute(:max_seats_used, 0)

        expect do
          ProjectGroupLink.last.update_attribute(:expires_at, 5.days.from_now)
        end.to change { gitlab_subscription.reload.max_seats_used }.from(0).to(2)
      end
    end

    context 'on destroy' do
      it 'updates the max_seats_used counter' do
        create_project_group_links

        gitlab_subscription.update_attribute(:max_seats_used, 0)

        expect do
          ProjectGroupLink.last.destroy
        end.to change { gitlab_subscription.reload.max_seats_used }.from(0).to(1)
      end
    end

    def create_project_group_links
      create(:project_group_link, project: project, group: invited_group_1, group_access: GroupMember::MAINTAINER)
      create(:project_group_link, project: project.reload, group: invited_group_2, group_access: GroupMember::MAINTAINER)
    end
  end
end
