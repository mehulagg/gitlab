# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Banzai::IssuableExtractor do
  it 'returns an instance of an epic for the node with reference' do
    epic = create(:epic)
    user = create(:user)
    epic_link = Nokogiri::HTML.fragment(
      "<a href='' data-epic='#{epic.id}' data-reference-type='epic' class='gfm'>text</a>"
    ).children[0]

    result = described_class.new(Banzai::RenderContext.new(nil, user)).extract([epic_link])

    expect(result).to eq(epic_link => epic)
  end
end
