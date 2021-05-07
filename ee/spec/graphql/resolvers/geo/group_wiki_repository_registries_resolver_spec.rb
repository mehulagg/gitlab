# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Geo::GroupWikiRepositoryRegistriesResolver do
  it_behaves_like 'a Geo registries resolver', :geo_group_wiki_repository_registry
end
