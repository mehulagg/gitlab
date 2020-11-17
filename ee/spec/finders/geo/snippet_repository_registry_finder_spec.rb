# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::SnippetRepositoryRegistryFinder do
  it_behaves_like 'a framework registry finder', :geo_snippet_repository_registry
end
