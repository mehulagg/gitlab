# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ImportExport::RepoRestorer do
  include GitHelpers

  let!(:project) { create(:project) }
  let(:export_path) { "#{Dir.tmpdir}/project_tree_saver_spec" }
  let(:shared) { project.import_export_shared }

  before do
    allow_next_instance_of(Gitlab::ImportExport) do |instance|
      allow(instance).to receive(:storage_path).and_return(export_path)
    end

    bundler.save
  end

  after do
    FileUtils.rm_rf(export_path)
    Gitlab::Shell.new.remove_repository(project.repository_storage, project.disk_path)
  end

  describe 'bundle a project Git repo' do
    let(:user) { create(:user) }
    let!(:project_with_repo) { create(:project, :repository, name: 'test-repo-restorer', path: 'test-repo-restorer') }

    let(:bundler) { Gitlab::ImportExport::RepoSaver.new(project: project_with_repo, shared: shared) }
    let(:bundle_path) { File.join(shared.export_path, Gitlab::ImportExport.project_bundle_filename) }

    subject { described_class.new(path_to_bundle: bundle_path, shared: shared, project: project) }

    after do
      Gitlab::Shell.new.remove_repository(project_with_repo.repository_storage, project_with_repo.disk_path)
    end

    it 'restores the repo successfully' do
      expect(subject.restore).to be_truthy
    end

    context 'when the repository already exists' do
      it 'deletes the existing repository before importing' do
        allow(project.repository).to receive(:exists?).and_return(true)
        allow(project.repository).to receive(:path).and_return('repository_path')

        expect_next_instance_of(Repositories::DestroyService) do |instance|
          expect(instance).to receive(:execute).and_call_original
        end

        expect(shared.logger).to receive(:info).with(
          message: 'Deleting existing "repository_path" to re-import it.'
        )

        expect(subject.restore).to be_truthy
      end
    end
  end

  describe 'restore a wiki Git repo' do
    let!(:project_with_wiki) { create(:project, :wiki_repo) }

    let(:shared) { project.import_export_shared }
    let(:bundler) { Gitlab::ImportExport::WikiRepoSaver.new(project: project_with_wiki, shared: shared) }
    let(:bundle_path) { File.join(shared.export_path, Gitlab::ImportExport.wiki_repo_bundle_filename) }

    subject { described_class.new(path_to_bundle: bundle_path, shared: shared, project: project.wiki) }

    after do
      Gitlab::Shell.new.remove_repository(project_with_wiki.wiki.repository_storage, project_with_wiki.wiki.disk_path)
    end

    it 'restores the wiki repo successfully' do
      expect(subject.restore).to be true
    end

    describe "no wiki in the bundle" do
      let!(:project_without_wiki) { create(:project) }

      let(:bundler) { Gitlab::ImportExport::WikiRepoSaver.new(project: project_without_wiki, shared: shared) }

      it 'does not creates an empty wiki' do
        expect(subject.restore).to be true

        expect(project.wiki_repository_exists?).to be false
      end
    end
  end
end
