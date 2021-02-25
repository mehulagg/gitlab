# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Usage::Docs::Renderer do
  describe 'contents' do
    let(:dictionary_path) { Gitlab::Usage::Docs::Renderer::DICTIONARY_PATH }
    let(:items) { Gitlab::Usage::MetricDefinition.definitions.first(10).to_h }

    it 'generates dictionary for given items' do
      generated_dictionary = described_class.new(items).contents

      generated_dictionary_keys = RDoc::Markdown
        .parse(generated_dictionary)
        .table_of_contents
        .select { |metric_doc| metric_doc.level == 3 }
        .map { |item| item.text.scan(/<code>.*<\/code>/).first.sub('<code>', '').sub('</code>', '') }

      expect(generated_dictionary_keys).to match_array(items.keys)
    end
  end
end
