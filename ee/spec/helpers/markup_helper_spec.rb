# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MarkupHelper do
  let(:project) { create(:project, :public) }

  describe '#first_line_in_markdown' do
    context 'with scoped label references' do
      let(:label) { create(:label, title: 'key::some name', project: project) }

      before do
        stub_licensed_features(scoped_labels: true)
      end

      it 'shows proper tooltip' do
        note = build(:note, note: label.to_reference, project: project)

        result = first_line_in_markdown(note, :note, nil, project: project)
        doc = Nokogiri::HTML.parse(result)

        expect(doc.css('.gl-label-link')[0].attr('data-html')).to eq('true')
      end
    end
  end
end
