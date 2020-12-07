# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Members::PermissionsExportService do
  let(:service) { described_class.new(current_user) }

  let_it_be(:admin) { create(:admin) }
  let_it_be(:user) { create(:user, username: 'Jessica', email: 'jessica@test.com') }

  context 'access', :enable_admin_mode do
    shared_examples 'allowed to export user permissions' do
      it { expect(service.csv_data).to be_success }
    end

    shared_examples 'not allowed to export user permissions' do
      it { expect(service.csv_data).not_to be_success }
    end

    before do
      stub_licensed_features(export_user_permissions: licensed)
    end

    context 'when user is an admin', :enable_admin_mode do
      let(:current_user) { admin }

      context 'when licensed' do
        let(:licensed) { true }

        it_behaves_like 'allowed to export user permissions'
      end

      context 'when not licensed' do
        let(:licensed) { false }

        it_behaves_like 'not allowed to export user permissions'
      end
    end

    context 'when user is not an admin' do
      let(:current_user) { user }

      context 'when licensed' do
        let(:licensed) { true }

        it_behaves_like 'not allowed to export user permissions'
      end

      context 'when not licensed' do
        let(:licensed) { false }

        it_behaves_like 'not allowed to export user permissions'
      end
    end
  end

  context 'data verification', :enable_admin_mode do
    subject(:csv) { CSV.parse(service.csv_data.payload.to_a.join, headers: true) }

    let_it_be(:current_user) { admin }
    let_it_be(:group) { create(:group) }
    let_it_be(:group_owner) { create(:group_member, :owner, group: group, user: user) }

    before do
      stub_licensed_features(export_user_permissions: true)
    end

    it 'includes the appropriate headers' do
      expect(csv.headers).to eq([
        'Username', 'Email', 'Type',
        'Path', 'Access Level', 'Inherited memberships'
      ])
    end

    specify 'Username' do
      expect(csv[0]['Username']).to eq('Jessica')
    end

    specify 'Email' do
      expect(csv[0]['Email']).to eq('jessica@test.com')
    end

    specify 'Type' do
      expect(csv[0]['Type']).to eq('Group') # needs fixing
    end

    specify 'Path' do
      expect(csv[0]['Path']).to eq(group.full_path)
    end

    specify 'Access Level' do
      expect(csv[0]['Access Level']).to eq('Owner')
    end

    context 'Inherited memberships' do
      let_it_be(:sub_group) { create(:group, parent: group) }
      let_it_be(:inherited_project) { create(:project, namespace: group) }

      specify do
        expect(csv[0]['Inherited memberships']).to eq("#{sub_group.full_path};#{inherited_project.full_path}")
      end
    end

    context 'when user is member of a sub group' do
      let_it_be(:sub_group) { create(:group, parent: group) }
      let_it_be(:sub_group_user) { create(:user, username: 'Oliver', email: 'oliver@test.com') }
      let_it_be(:sub_group_maintainer) { create(:group_member, :maintainer, group: sub_group, user: sub_group_user) }

      specify 'displays attributes correctly', :aggregate_failures do
        row = csv.find { |row| row['Username'] == 'Oliver' }

        expect(row['Path']).to eq(sub_group.full_path)
        expect(row['Type']).to eq('Sub group')
        expect(row['Access Level']).to eq('Maintainer')
      end
    end

    context 'when user is member of a project' do
      let_it_be(:project) { create(:project, namespace: group) }
      let_it_be(:project_user) { create(:user, username: 'Theo', email: 'theo@test.com') }
      let_it_be(:project_developer) { create(:project_member, :developer, project: project, user: project_user) }

      specify 'displays attributes correctly', :aggregate_failures do
        row = csv.find { |row| row['Username'] == 'Theo' }

        expect(row['Path']).to eq(project.full_path)
        expect(row['Type']).to eq('Project')
        expect(row['Access Level']).to eq('Developer')
      end
    end

    context 'when member user is blocked' do
      let_it_be(:blocked_user) { create(:user, :blocked, username: 'Helvi', email: 'helvi@test.com') }
      let_it_be(:blocked_member) { create(:group_member, :maintainer, group: group, user: blocked_user) }

      it 'does not report the member' do
        row = csv.find { |row| row['Username'] == 'Helvi' }

        expect(row).to be nil
      end
    end

    context 'when member request is pending' do
      let_it_be(:requested_user) { create(:user, username: 'Iris', email: 'iris@test.com') }
      let_it_be(:requested_member) { create(:group_member, :maintainer, group: group, user: requested_user, requested_at: 2.days.ago) }

      it 'does not report the member' do
        row = csv.find { |row| row['Username'] == 'Iris' }

        expect(row).to be nil
      end
    end
  end
end
