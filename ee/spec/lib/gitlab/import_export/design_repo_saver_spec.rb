# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::DesignRepoSaver do
  describe 'bundle a design Git repo' do
    set(:user) { create(:user) }
    set(:design) { create(:design, :with_file, versions_count: 1) }
    let!(:project) { create(:project, :design_repo) }
    let(:export_path) { "#{Dir.tmpdir}/project_tree_saver_spec" }
    let(:shared) { project.import_export_shared }
    let(:design_bundler) { described_class.new(project: project, shared: shared) }

    before do
      project.add_maintainer(user)
      allow_any_instance_of(Gitlab::ImportExport).to receive(:storage_path).and_return(export_path)
    end

    after do
      FileUtils.rm_rf(export_path)
    end

    it 'bundles the repo successfully' do
      expect(design_bundler.save).to be true
    end

    context 'when the repo is empty' do
      let!(:project) { create(:project) }

      it 'bundles the repo successfully' do
        expect(design_bundler.save).to be true
      end
    end
  end
end
