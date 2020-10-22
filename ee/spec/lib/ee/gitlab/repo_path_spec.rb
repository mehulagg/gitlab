# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::RepoPath do
  describe '.find_project' do
    let(:project) { create(:project) }

    context 'without premium license' do
      context 'project_path matches a project alias' do
        let(:project_alias) { create(:project_alias, project: project) }

        it 'does not return a project' do
          expect(described_class.find_project(project_alias.name)).to eq([nil, nil])
        end
      end
    end

    context 'with premium license' do
      before do
        stub_licensed_features(project_aliases: true)
      end

      context 'project_path matches a project alias' do
        let(:project_alias) { create(:project_alias, project: project) }

        it 'returns the project' do
          expect(described_class.find_project(project_alias.name)).to eq([project, nil])
        end
      end

      context 'project_path does not match a project alias' do
        context 'project path matches project full path' do
          it 'returns the project' do
            expect(described_class.find_project(project.full_path)).to eq([project, nil])
          end
        end

        context 'project path does not match an existing project full path' do
          it 'returns nil' do
            expect(described_class.find_project('some-project')).to eq([nil, nil])
          end
        end
      end
    end
  end
end
