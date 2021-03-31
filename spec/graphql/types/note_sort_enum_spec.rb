# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['NoteSort'] do
  specify { expect(described_class.graphql_name).to eq('NoteSort') }

  it 'exposes all the existing note sort values' do
    expect(described_class.values.keys).to include(
      *%w[CREATED_AT_ASC CREATED_AT_DESC]
    )
  end
end
