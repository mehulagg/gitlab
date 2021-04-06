# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::GroupWikiRepositoryReplicator do
  let(:model_record) { build(:group_wiki_repository, group: create(:group)) }

  include_examples 'a repository replicator'
end
