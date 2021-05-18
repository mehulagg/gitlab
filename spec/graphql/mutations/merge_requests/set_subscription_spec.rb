# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::MergeRequests::SetSubscription do
  it_behaves_like 'a subscribeable graphql resource' do
    let_it_be_with_reload(:project) { create(:project) }
    let(:resource) { create(:merge_request, source_project: project, target_project: project) }
  end
end
