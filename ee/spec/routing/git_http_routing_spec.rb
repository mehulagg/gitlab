# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'EE git_http routing' do
  describe 'Geo routing' do
    it_behaves_like 'git repository routes' do
      let(:path) { '/-/push_from_secondary/node/gitlab-org/gitlab-test.git' }
      let(:container_path) { '/gitlab-org/gitlab-test' }
      let(:params) { { geo_node_id: 'node', repository_path: 'gitlab-org/gitlab-test.git' } }
    end

    it_behaves_like 'git repository routes with fallback for git-upload-pack' do
      let(:path) { '/-/push_from_secondary/node/gitlab-org/gitlab-test.git' }
      let(:container_path) { '/gitlab-org/gitlab-test' }
      let(:params) { { geo_node_id: 'node', repository_path: 'gitlab-org/gitlab-test.git' } }
    end
  end
end
