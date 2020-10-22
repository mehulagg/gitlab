# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ProtectedEnvironment do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:deploy_access_levels) }
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:deploy_access_levels) }
  end

  describe '#accessible_to?' do
    let(:project) { create(:project) }
    let(:environment) { create(:environment, project: project) }
    let(:protected_environment) { create(:protected_environment, name: environment.name, project: project) }
    let(:user) { create(:user) }

    subject { protected_environment.accessible_to?(user) }

    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be_truthy }
    end

    context 'when access has been granted to user' do
      before do
        create_deploy_access_level(user: user)
      end

      it { is_expected.to be_truthy }
    end

    context 'when specific access has been assigned to a group' do
      let(:group) { create(:group) }

      before do
        create_deploy_access_level(group: group)
      end

      it 'allows members of the group' do
        group.add_developer(user)

        expect(subject).to be_truthy
      end

      it 'rejects non-members of the group' do
        expect(subject).to be_falsy
      end
    end

    context 'when access has been granted to maintainers' do
      before do
        create_deploy_access_level(access_level: Gitlab::Access::MAINTAINER)
      end

      it 'allows maintainers' do
        project.add_maintainer(user)

        expect(subject).to be_truthy
      end

      it 'rejects developers' do
        project.add_developer(user)

        expect(subject).to be_falsy
      end
    end

    context 'when access has been granted to developers' do
      before do
        create_deploy_access_level(access_level: Gitlab::Access::DEVELOPER)
      end

      it 'allows maintainers' do
        project.add_maintainer(user)

        expect(subject).to be_truthy
      end

      it 'allows developers' do
        project.add_developer(user)

        expect(subject).to be_truthy
      end
    end
  end

  describe '.sorted_by_name' do
    subject(:protected_environments) { described_class.sorted_by_name }

    it "sorts protected environments by name" do
      %w(staging production development).each {|name| create(:protected_environment, name: name)}

      expect(protected_environments.map(&:name)).to eq %w(development production staging)
    end
  end

  describe '.with_environment_id' do
    subject(:protected_environments) { described_class.with_environment_id }

    it "sets corresponding environment id if there is environment matching by name and project" do
      project = create(:project)
      environment = create(:environment, project: project, name: 'production')

      production = create(:protected_environment, project: project, name: 'production')
      removed_environment = create(:protected_environment, project: project, name: 'removed environment')

      expect(protected_environments).to match_array [production, removed_environment]
      expect(protected_environments.find {|e| e.name == 'production'}.environment_id).to eq environment.id
      expect(protected_environments.find {|e| e.name == 'removed environment'}.environment_id).to be_nil
    end
  end

  describe '.deploy_access_levels_by_group' do
    let(:group) { create(:group) }
    let(:project) { create(:project) }
    let(:environment) { create(:environment, project: project, name: 'production') }
    let(:protected_environment) { create(:protected_environment, project: project, name: 'production') }

    it 'returns matching deploy access levels for the given group' do
      _deploy_access_level_for_different_group = create_deploy_access_level(group: create(:group))
      _deploy_access_level_for_user = create_deploy_access_level(user: create(:user))
      deploy_access_level = create_deploy_access_level(group: group)

      expect(described_class.deploy_access_levels_by_group(group)).to contain_exactly(deploy_access_level)
    end
  end

  def create_deploy_access_level(**opts)
    protected_environment.deploy_access_levels.create(**opts)
  end
end
