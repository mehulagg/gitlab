# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SubscriptionPortal::Client do
  subject { described_class }

  it { is_expected.to include_module Gitlab::SubscriptionPortal::Clients::Graphql }
  it { is_expected.to include_module Gitlab::SubscriptionPortal::Clients::Rest }
end
