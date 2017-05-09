require 'spec_helper'

describe Gitlab::GitAccessWiki, lib: true do
  let(:access) { Gitlab::GitAccessWiki.new(user, project, 'web', authentication_abilities: authentication_abilities, redirected_path: redirected_path) }
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }
  let(:changes) { ['6f6d7e7ed 570e7b2ab refs/heads/master'] }
  let(:redirected_path) { nil }
  let(:authentication_abilities) do
    [
      :read_project,
      :download_code,
      :push_code
    ]
  end

  describe '#push_access_check' do
    context 'when user can :create_wiki' do
      before do
        create(:protected_branch, name: 'master', project: project)
        project.team << [user, :developer]
      end

      subject { access.check('git-receive-pack', changes) }

      it { expect(subject.allowed?).to be_truthy }

      context 'when in a secondary gitlab geo node' do
        before do
          allow(Gitlab::Geo).to receive(:enabled?) { true }
          allow(Gitlab::Geo).to receive(:secondary?) { true }
        end

        it { expect(subject.allowed?).to be_falsey }
      end
    end
  end

  describe '#access_check_download!' do
    subject { access.check('git-upload-pack', '_any') }

    before do
      project.team << [user, :developer]
    end

    context 'when wiki feature is enabled' do
      it 'give access to download wiki code' do
        expect(subject.allowed?).to be_truthy
      end
    end

    context 'when wiki feature is disabled' do
      it 'does not give access to download wiki code' do
        project.project_feature.update_attribute(:wiki_access_level, ProjectFeature::DISABLED)

        expect(subject.allowed?).to be_falsey
        expect(subject.message).to match(/You are not allowed to download code/)
      end
    end
  end
end
