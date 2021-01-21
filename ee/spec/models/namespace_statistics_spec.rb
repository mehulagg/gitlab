# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespaceStatistics do
  it { is_expected.to belong_to(:namespace) }

  it { is_expected.to validate_presence_of(:namespace) }
end
