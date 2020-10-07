# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Merge request > User edits MR with multiple reviewers' do
  include_context 'merge request edit context'

  before do
    stub_licensed_features(multiple_merge_request_reviewers: true)
  end

  it_behaves_like 'multiple reviewers merge request', 'updates', 'Save changes'
end
