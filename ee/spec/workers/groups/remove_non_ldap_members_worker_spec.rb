# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::RemoveNonLdapMembersWorker, type: :worker do
  include LdapHelpers

  describe '#perform' do
    let_it_be(:user) { create(:user) }
    let_it_be(:group) { create(:group) }

    before do
      create(:group_member, :developer, group: group)

      ldap_user = create(:omniauth_user, provider: "ldapmain")
      create(:group_member, :developer, :ldap, group: group, user: ldap_user)
    end

    shared_examples 'an unlocked group' do
      it 'does not remove users' do
        expect do
          subject.perform(group.id, user.id)
        end.not_to change { group.reload.users.count }
      end
    end

    context 'ldap is enabled' do
      before do
        stub_ldap_setting(enabled: true)
      end

      context 'admin allows owners to modify ldap settings' do
        before do
          stub_application_setting(allow_group_owners_to_manage_ldap: true)
        end

        context 'when ldap_settings_unlock_groups_by_owners is enabled' do
          before do
            stub_feature_flags(ldap_settings_unlock_groups_by_owners: true)
          end

          context 'user is a group admin' do
            before do
              group.add_owner(user)
            end

            context 'group is unlocked to ldap' do
              before do
                group.update_attribute(:unlock_membership_to_ldap, true)
              end

              it_behaves_like 'an unlocked group'
            end

            context 'group is locked to ldap' do
              before do
                group.update_attribute(:unlock_membership_to_ldap, false)
              end

              it 'removes users' do
                expect do
                  subject.perform(group.id, user.id)
                end.to change { group.reload.users.count }.by(-1)
              end

              context 'inderect user via project' do
                let_it_be(:project) { create(:project, group: group) }
                let_it_be(:project_member) { create(:project_member, project: project) }

                it 'removes the project member' do
                  expect do
                    binding.pry
                    subject.perform(group.id, user.id)
                    binding.pry
                  end.to change(project_member.reload, :persisted?)
                end
              end

              context 'inderect user via subgroup' do
                let_it_be(:subproject) 
              end
            end
          end

          context "user isn't a group admin" do
            it_behaves_like 'an unlocked group'
          end
        end

        context 'when ldap_settings_unlock_groups_by_owners is disabled' do
          before do
            stub_feature_flags(ldap_settings_unlock_groups_by_owners: false)
          end

          it_behaves_like 'an unlocked group'
        end
      end

      context 'admin disallows owners to modify ldap settings' do
        before do
          stub_application_setting(allow_group_owners_to_manage_ldap: false)
        end

        it_behaves_like 'an unlocked group'
      end
    end

    context 'when ldap is disabled' do
      before do
        stub_ldap_setting(enabled: true)
      end

      it_behaves_like 'an unlocked group'
    end
  end
end
