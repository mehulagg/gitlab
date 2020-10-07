# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::SnippetRepositoryReplicator do
  let(:model_record) { build(:snippet_repository, snippet: create(:snippet)) }

  include_examples 'a repository replicator'
end
