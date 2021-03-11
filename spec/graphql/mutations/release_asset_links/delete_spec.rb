# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::ReleaseAssetLinks::Delete do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :private, :repository) }
  let_it_be(:release) { create(:release, project: project) }
  let_it_be(:developer) { create(:user).tap { |u| project.add_developer(u) } }
  let_it_be(:maintainer) { create(:user).tap { |u| project.add_maintainer(u) } }
  let_it_be(:release_link) { create(:release_link, release: release) }

  let(:current_user) { maintainer }
  let(:mutation) { described_class.new(object: nil, context: { current_user: current_user }, field: nil) }
  let(:mutation_arguments) { { id: release_link.to_global_id } }

  describe '#resolve' do
    subject(:resolve) do
      mutation.resolve(**mutation_arguments)
    end

    let(:deleted_link) { subject[:link] }

    context 'when the current user has access to delete the link' do
      it 'deletes the link and returns it' do

        # TODO: not working
        link_to_be_deleted = release.links.last
        expect(deleted_link).to eq(link_to_be_deleted)
      end
    end

    context 'when the current user does not have access to update the link' do
      let(:current_user) { developer }

      it 'raises an error' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable, "The resource that you are attempting to access does not exist or you don't have permission to perform this action")
      end
    end

    context "when the link doesn't exist" do
      let(:mutation_arguments) { super().merge(id: 'gid://gitlab/Releases::Link/999999') }

      it 'raises an error' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable, "The resource that you are attempting to access does not exist or you don't have permission to perform this action")
      end
    end
  end
end
