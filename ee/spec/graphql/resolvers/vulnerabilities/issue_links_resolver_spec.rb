# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Vulnerabilities::IssueLinksResolver do
  include GraphqlHelpers

  describe '#resolve' do
    let_it_be(:user) { create(:user) }
    let_it_be(:vulnerability) { create(:vulnerability) }
    let_it_be(:related_issue) { create(:vulnerabilities_issue_link, :related, vulnerability: vulnerability) }
    let_it_be(:created_issue) { create(:vulnerabilities_issue_link, :created, vulnerability: vulnerability) }

    subject { resolve(described_class, obj: vulnerability, args: filters, ctx: { current_user: user }) }

    context 'when there is no filter given' do
      let(:filters) { {} }

      it { is_expected.to match_array([related_issue, created_issue]) }
    end

    context 'when the link_type filter is given' do
      context 'when the filter is `CREATED`' do
        let(:filters) { { link_type: 'CREATED' } }

        it { is_expected.to match_array([created_issue]) }
      end

      context 'when the filter is `RELATED`' do
        let(:filters) { { link_type: 'RELATED' } }

        it { is_expected.to match_array([related_issue]) }
      end
    end
  end
end
