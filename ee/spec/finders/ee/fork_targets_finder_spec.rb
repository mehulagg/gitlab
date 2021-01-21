# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ForkTargetsFinder do
  subject(:finder) { described_class.new(project, user) }

  let(:project) { create :project, namespace: project_group }

  describe '#execute' do
    subject(:fork_targets) { finder.execute }

    let(:user) { create :user, :group_managed, managing_group: project_group }

    let(:outer_group) { create :group }
    let(:inner_subgroup) { create(:group, :nested, parent: project_group) }

    before do
      project_group.add_reporter(user)
      outer_group.add_owner(user)
      inner_subgroup.add_owner(user)
      stub_licensed_features(group_saml: true, group_forking_protection: true)
    end

    context 'when project root group prohibits outer forks' do
      context 'when it is configured on saml level' do
        let(:project_group) do
          create(:saml_provider, :enforced_group_managed_accounts, prohibited_outer_forks: true).group
        end

        it 'returns namespaces with the same root group as project one only' do
          expect(fork_targets).to be_a(ActiveRecord::Relation)
          expect(fork_targets).to match_array([inner_subgroup])
        end

        context 'when project root does not prohibit outer forks' do
          let(:project_group) do
            create(:saml_provider, :enforced_group_managed_accounts, prohibited_outer_forks: false).group
          end

          it 'returns outer namespaces as well as inner' do
            expect(fork_targets).to be_a(ActiveRecord::Relation)
            expect(fork_targets).to match_array([outer_group, inner_subgroup, user.namespace])
          end
        end
      end

      context 'when it is configured on group level' do
        let(:project_group) do
          create(:group)
        end

        let(:user) { create :user }

        context 'when project root prohibits outer forks' do
          before do
            project_group.namespace_settings.update!(prevent_forking_outside_group: true)
          end

          it 'returns namespaces with the same root group as project one only' do
            expect(fork_targets).to be_a(ActiveRecord::Relation)
            expect(fork_targets).to match_array([inner_subgroup])
          end
        end

        context 'when project root does not prohibit outer forks' do
          it 'returns outer namespaces as well as inner' do
            expect(fork_targets).to be_a(ActiveRecord::Relation)
            expect(fork_targets).to match_array([outer_group, inner_subgroup, user.namespace])
          end
        end
      end
    end
  end
end
