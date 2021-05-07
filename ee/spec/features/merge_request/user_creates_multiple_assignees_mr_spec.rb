# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Merge request > User creates MR with multiple assignees' do
  include_context 'merge request create context'

  before do
    stub_licensed_features(multiple_merge_request_assignees: true)
  end

  it_behaves_like 'multiple assignees merge request', 'creates', 'Create merge request'
end
