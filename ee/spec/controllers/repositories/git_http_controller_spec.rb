# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::GitHttpController do
  context 'when repository container is a group wiki' do
    include WikiHelpers

    let_it_be(:group) { create(:group, :wiki_repo) }
    let_it_be(:user) { create(:user) }

    before_all do
      group.add_owner(user)
    end

    before do
      stub_group_wikis(true)
    end

    it_behaves_like Repositories::GitHttpController do
      let(:container) { group.wiki }
      let(:access_checker_class) { Gitlab::GitAccessWiki }
    end
  end
end
