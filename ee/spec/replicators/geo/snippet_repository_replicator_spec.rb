# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::SnippetRepositoryReplicator, let_it_be_light_freeze: false do
  let(:snippet) { create(:snippet, :repository) }
  let(:model_record) { snippet.snippet_repository }

  include_examples 'a repository replicator'
  it_behaves_like 'a verifiable replicator'
end
