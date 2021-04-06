# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::BlobsResolver do
  include GraphqlHelpers

  describe '#resolve' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project, :repository) }

    let(:repository) { project.repository }
    let(:args) { { paths: paths, ref: ref } }
    let(:paths) { [] }
    let(:ref) { nil }

    subject(:resolve_blobs) { resolve(described_class, obj: repository, args: args, ctx: { current_user: user }) }

    context 'when unauthorized' do
      it 'raises an exception' do
        expect { resolve_blobs }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when authorized' do
      before do
        project.add_developer(user)
      end

      context 'using no filter' do
        it 'returns nothing' do
          is_expected.to be_empty
        end
      end

      context 'using paths filter' do
        let(:paths) { ['README.md'] }

        it 'returns the specified blobs for HEAD' do
          is_expected.to contain_exactly(have_attributes(path: 'README.md'))
        end

        context 'specifying a non-existent blob' do
          let(:paths) { ['non-existent'] }

          it 'returns nothing' do
            is_expected.to be_empty
          end
        end

        context 'specifying a different ref' do
          let(:ref) { 'improve/awesome' }

          it 'returns the specified blobs for that ref' do
            is_expected.to contain_exactly(have_attributes(path: 'README.md'))
          end
        end
      end
    end
  end
end
