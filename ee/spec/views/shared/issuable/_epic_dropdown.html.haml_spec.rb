# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'shared/issuable/_epic_dropdown.html.haml' do
  it_behaves_like 'issuable bulk dropdown', 'shared/issuable/epic_dropdown' do
    let(:feature_id) { :epics }
    let(:input_selector) { 'input#issue_epic_id[name="update[epic_id]"]' }
    let(:root_selector) { "#js-epic-select-root[data-group-id=\"#{parent.id}\"][data-show-header=\"true\"]" }
  end
end
