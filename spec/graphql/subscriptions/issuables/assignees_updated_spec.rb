# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Subscriptions::Issuables::AssigneesUpdated do
  include GraphqlHelpers

  let_it_be(:unauthorized_user) { create(:user) }

  it { expect(described_class).to have_graphql_arguments(:issuable_id) }
  it { expect(described_class.payload_type).to eq([Types::UserType]) }

  describe '#authorized?' do
    let(:resolver) { resolver_instance(described_class, ctx: { current_user: current_user }) }

    subject { resolver.authorized?(issuable_id: issuable_id) }

    context 'with an issue' do
      let_it_be(:issue) { create(:issue) }

      let(:current_user) { issue.author }
      let(:issuable_id) { issue.to_gid }

      context 'unauthorized user' do
        let(:current_user) { unauthorized_user }

        it { is_expected.to eq(false) }
      end

      context 'authorized user' do
        it { is_expected.to eq(true) }
      end

      context 'when issue does not exist' do
        let(:issuable_id) { GlobalID.parse("gid://gitlab/Issue/#{non_existing_record_id}") }

        it { is_expected.to be_falsey }
      end

      context 'when a GraphQL::ID_TYPE is provided' do
        let(:issuable_id) { issue.to_gid.to_s }

        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
        end
      end
    end

    context 'with a merge request' do
      let_it_be(:merge_request) { create(:merge_request) }

      let(:current_user) { merge_request.author }
      let(:issuable_id) { merge_request.to_gid }

      it 'raises an exception' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
      end
    end
  end
end
