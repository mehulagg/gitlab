# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::Latest::SnippetInstanceProxy do
  let(:snippet) { create(:personal_snippet) }

  subject { described_class.new(snippet) }

  describe '#as_indexed_json' do
    it 'serializes snippet as hash' do
      expect(subject.as_indexed_json.with_indifferent_access).to include(
        id: snippet.id,
        title: snippet.title,
        description: snippet.description,
        created_at: snippet.created_at,
        updated_at: snippet.updated_at,
        project_id: snippet.project_id,
        author_id: snippet.author_id,
        visibility_level: snippet.visibility_level
      )
    end
  end
end
