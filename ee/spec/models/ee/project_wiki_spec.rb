# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectWiki do
  it_behaves_like 'EE wiki model' do
    let(:wiki_container) { create(:project, :wiki_repo, namespace: user.namespace) }

    it 'uses Elasticsearch' do
      expect(subject).to be_a(Elastic::WikiRepositoriesSearch)
    end
  end
end
