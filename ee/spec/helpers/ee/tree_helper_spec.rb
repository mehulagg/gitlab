# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TreeHelper do
  let(:project) { create(:project, :repository) }

  describe '#tree_content_data' do
    let(:logs_path) { "#{project.full_path}/refs/master/logs_tree/" }
    let(:path) { '.gitlab/template_test' }

    context 'when file locks is available' do
      it 'returns the logs path' do
        stub_licensed_features(file_locks: true)

        tree_content_data = {
          "logs-path" => logs_path,
          "path-locks-available" => "true",
          "path-locks-toggle" => toggle_project_path_locks_path(project),
          "path-locks-path" => path
        }

        expect(helper.tree_content_data(logs_path, project, path)).to eq(tree_content_data)
      end
    end

    context 'when file lock is not available' do
      it 'returns the path information' do
        stub_licensed_features(file_locks: false)

        tree_content_data = {
          "logs-path" => logs_path,
          "path-locks-available" => "false",
          "path-locks-toggle" => toggle_project_path_locks_path(project),
          "path-locks-path" => path
        }

        expect(helper.tree_content_data(logs_path, project, path)).to eq(tree_content_data)
      end
    end
  end
end
