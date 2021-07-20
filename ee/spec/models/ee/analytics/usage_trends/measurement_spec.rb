# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::UsageTrends::Measurement do
  describe '.identifier_query_mapping' do
    subject { described_class.identifier_query_mapping.keys }

    it { is_expected.to include described_class.identifiers[:billable_users] }
  end

  describe '.identifier_min_max_queries' do
    subject { described_class.identifier_min_max_queries.keys }

    it { is_expected.to include described_class.identifiers[:billable_users] }
  end
end
