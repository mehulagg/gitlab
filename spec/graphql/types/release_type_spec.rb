# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['Release'] do
  it { expect(described_class.graphql_name).to eq('Release') }

  it { expect(described_class).to require_graphql_authorizations(:read_release) }

  it 'has the expected fields' do
    expected_fields = %w[
      tag_name tag_path
      description description_html
      name evidence_sha assets milestones author commit
      created_at updated_at released_at
    ]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end

  describe 'assets field' do
    subject { described_class.fields['assets'] }

    it { is_expected.to have_graphql_type(Types::ReleaseAssetsType) }
  end

  describe 'milestones field' do
    subject { described_class.fields['milestones'] }

    it { is_expected.to have_graphql_type(Types::MilestoneType.connection_type) }
  end

  describe 'milestones field' do
    subject { described_class.fields['author'] }

    it { is_expected.to have_graphql_type(Types::UserType) }
  end

  describe 'commit field' do
    subject { described_class.fields['commit'] }

    it { is_expected.to have_graphql_type(Types::CommitType) }
    it { is_expected.to require_graphql_authorizations(:reporter_access) }
  end
end
