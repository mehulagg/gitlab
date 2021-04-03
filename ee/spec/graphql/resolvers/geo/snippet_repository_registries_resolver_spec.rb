# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Geo::SnippetRepositoryRegistriesResolver do
  it_behaves_like 'a Geo registries resolver', :geo_snippet_repository_registry
end
