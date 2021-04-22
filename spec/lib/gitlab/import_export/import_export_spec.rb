# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ImportExport do
  describe 'export filename' do
    let(:group) { build(:group, path: 'child', parent: build(:group, path: 'parent')) }
    let(:project) { build(:project, :public, path: 'project-path', namespace: group) }

    it 'contains the project path' do
      expect(described_class.export_filename(exportable: project)).to include(project.path)
    end

    it 'contains the namespace path' do
      expect(described_class.export_filename(exportable: project)).to include(project.namespace.full_path.tr('/', '_'))
    end

    it 'does not go over a certain length' do
      project.path = 'a' * 100

      expect(described_class.export_filename(exportable: project).length).to be < 70
    end
  end

  describe '#snippet_repo_bundle_filename_for' do
    let(:snippet) { build(:snippet, id: 1) }

    it 'generates the snippet bundle name' do
      expect(described_class.snippet_repo_bundle_filename_for(snippet)).to eq "#{snippet.hexdigest}.bundle"
    end
  end

  describe '.top_level_relations' do
    shared_examples 'returns a list of top level relations' do
      it 'returns a list of top level relations' do
        config = ::Gitlab::ImportExport::Config.new(config: yaml).to_h
        expected = config.dig(:tree, exportable.class.name.downcase.to_sym).keys.map(&:to_s)

        expect(described_class.top_level_relations(exportable.class.name)).to eq(expected)
      end
    end

    context 'when exportable is group' do
      let(:exportable) { create(:group) }
      let(:yaml) { ::Gitlab::ImportExport.group_config_file }

      include_examples 'returns a list of top level relations'
    end

    context 'when exportable is project' do
      let(:exportable) { create(:project) }
      let(:yaml) { ::Gitlab::ImportExport.config_file }

      include_examples 'returns a list of top level relations'
    end
  end

  describe '.import_export_yaml' do
    context 'when exportable is group' do
      it 'returns group config filepath' do
        expect(described_class.import_export_yaml('Group')).to eq(::Gitlab::ImportExport.group_config_file)
      end
    end

    context 'when exportable is project' do
      it 'returns project config filepath' do
        expect(described_class.import_export_yaml('Project')).to eq(::Gitlab::ImportExport.config_file)
      end
    end

    context 'when exportable is unsupported' do
      it 'raises unsupported object type error' do
        expect { described_class.import_export_yaml('unsupported') }.to raise_error(::Gitlab::ImportExport::Error)
      end
    end
  end
end
