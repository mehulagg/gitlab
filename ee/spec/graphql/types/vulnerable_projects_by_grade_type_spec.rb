# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['VulnerableProjectsByGrade'] do
  let(:fields) { %w(grade count projects).freeze }

  specify { expect(described_class).to have_graphql_fields(fields) }
  specify { expect(described_class.graphql_name).to eq('VulnerableProjectsByGrade') }
end
