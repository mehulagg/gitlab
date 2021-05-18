# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Issues::SetSubscription do
  it_behaves_like 'a subscribeable graphql resource' do
    let_it_be_with_reload(:project) { create(:project) }
    let_it_be(:resource) { create(:issue, project: project) }
  end
end
