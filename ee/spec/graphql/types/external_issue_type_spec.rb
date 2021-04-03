# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ExternalIssue'] do
  let(:expected_fields) { %i[title relative_reference status external_tracker web_url created_at updated_at] }

  subject { described_class }

  it { is_expected.to have_graphql_fields(expected_fields) }
end
