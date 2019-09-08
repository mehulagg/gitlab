require 'spec_helper'

describe ReferableIssueTrackerService do
  include Gitlab::Routing
  include AssetsHelpers

  it_behaves_like "ReferableIssueTrackerService"
end
