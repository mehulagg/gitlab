# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ApiFuzzingScanProfile'] do
  let_it_be(:fields) { %i[name description yaml] }

  it { expect(described_class).to have_graphql_fields(fields) }
end
