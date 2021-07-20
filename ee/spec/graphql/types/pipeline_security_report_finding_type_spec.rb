# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['PipelineSecurityReportFinding'] do
  let_it_be(:fields) do
    %i[report_type
       name
       severity
       confidence
       scanner
       identifiers
       project_fingerprint
       uuid
       project
       description
       location
       solution
       state]
  end

  specify { expect(described_class.graphql_name).to eq('PipelineSecurityReportFinding') }

  it { expect(described_class).to have_graphql_fields(fields) }
end
