# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::GroupWikiRepositoryRegistryFinder do
  it_behaves_like 'a framework registry finder', :geo_group_wiki_repository_registry
end
