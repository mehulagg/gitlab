# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GlRepository::RepoType do
  describe Gitlab::GlRepository::WIKI do
    context 'group wiki' do
      let_it_be(:group) { create(:group) }

      it_behaves_like 'a repo type' do
        let(:expected_id) { group.id }
        let(:expected_identifier) { "group-#{expected_id}-wiki" }
        let(:expected_suffix) { '.wiki' }
        let(:expected_container) { group }
        let(:expected_repository) { ::Repository.new(group.wiki.full_path, group, shard: group.wiki.repository_storage, disk_path: group.wiki.disk_path, repo_type: Gitlab::GlRepository::WIKI) }
      end
    end
  end
end
