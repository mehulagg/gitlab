# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::ReleaseAssetLinks::Create do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :private, :repository) }
  let_it_be(:release) { create(:release, project: project, tag: 'v13.10') }
  let_it_be(:reporter) { create(:user).tap { |u| project.add_reporter(u) } }
  let_it_be(:developer) { create(:user).tap { |u| project.add_developer(u) } }

  let(:current_user) { developer }
  let(:tag) { release.tag }
  let(:name) { 'awesome-app.dmg' }
  let(:url) { 'https://example.com/download/awesome-app.dmg' }

  let(:args) do
    {
      project_path: project.full_path,
      tag: tag,
      name: name,
      filepath: '/binaries/awesome-app.dmg',
      url: url
    }
  end

  let(:last_release_link) { release.links.last }

  it 'creates a new release asset link' do
    resolve_asset_link

    release.reload

    expect(release.links.length).to be(1)

    expect(last_release_link.name).to eq(args[:name])
    expect(last_release_link.url).to eq(args[:url])
    expect(last_release_link.filepath).to eq(args[:filepath])
  end

  context "when the user doesn't have access to the project or the project doesn't exist" do
    let(:current_user) { reporter }

    it 'raises an error' do
      expect { resolve_asset_link }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end
  end

  context "when the release doesn't exist" do
    let(:tag) { "nonexistent-tag" }

    it 'raises an error' do
      expect { resolve_asset_link }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable, "release with tag #{tag} was not found in project #{project.full_path}")
    end
  end

  context "when a validation errors occur" do
    shared_examples 'raises an error' do
      it { expect { resolve_asset_link }.to raise_error(Gitlab::Graphql::Errors::BaseError) }
    end

    context 'when the URL is badly formatted' do
      let(:url) { 'badly-formatted-url' }

      it_behaves_like 'raises an error'
    end

    context 'when the URL is badly formatted' do
      let(:name) { '' }

      it_behaves_like 'raises an error'
    end

    context 'when the link already exists' do
      before do
        resolve_asset_link
      end

      it_behaves_like 'raises an error'
    end
  end

  def resolve_asset_link
    context = { current_user: current_user }
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
