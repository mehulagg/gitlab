# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UsersSecurityDashboardProject do
  subject { build(:users_security_dashboard_project) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_uniqueness_of(:project_id).scoped_to(:user_id) }

    context 'when validating the number of projects a user can add to their dashboard' do
      before do
        stub_const("UsersSecurityDashboardProject::SECURITY_DASHBOARD_PROJECTS_LIMIT", 1)
      end

      it 'limits the number of projects per user' do
        user = create(:user)
        create(:users_security_dashboard_project, user: user)

        dashboard_project = build(:users_security_dashboard_project, user: user)

        expect(dashboard_project).to be_invalid
        expect(dashboard_project.errors.full_messages).to include('Project limit of 1 reached')
      end

      it 'allows a user to add a project if they are under the limit' do
        dashboard_project = build(:users_security_dashboard_project)

        expect(dashboard_project).to be_valid
      end
    end
  end

  describe '.delete_by_project_id' do
    it 'deletes all entries for the given project ID' do
      project = create(:project)
      dashboard_project = create(:users_security_dashboard_project, project: project)

      result = described_class.delete_by_project_id(project.id)

      expect(result).to be(1)
      expect { dashboard_project.reload }.to raise_exception(ActiveRecord::UnknownPrimaryKey)
    end

    context 'when there is no record with the given project ID' do
      it 'fails silently' do
        expect(described_class.delete_by_project_id(-1)).to be_zero
      end
    end
  end
end
