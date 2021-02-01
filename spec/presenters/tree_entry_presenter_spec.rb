# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TreeEntryPresenter do
  include Gitlab::Routing.url_helpers

  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }
  let(:git_tree) { repository.tree.trees.first }
  let(:tree) { Blob.new(git_tree, project) }
  let(:presenter) { described_class.new(tree) }

  describe '.web_url' do
    it { expect(presenter.web_url).to eq("http://localhost/#{project.full_path}/-/tree/#{tree.commit_id}/#{tree.path}") }
  end

  describe '#web_path' do
    it { expect(presenter.web_path).to eq("/#{project.full_path}/-/tree/#{tree.commit_id}/#{tree.path}") }
  end
end
