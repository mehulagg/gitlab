# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Ci::RetryBuildService do
  it_behaves_like 'restricts access to protected environments'

  describe '#reprocess' do
    context 'when user has ability to execute build' do
      let(:user) { create(:user) }
      let(:build) { create(:ci_build) }
      let(:project) { build.project }

      subject(:service) { described_class.new(project, user) }

      let(:new_build) do
        travel_to(1.second.from_now) do
          service.reprocess!(build)
        end
      end

      before do
        stub_not_protect_default_branch

        project.add_developer(user)
      end

      context 'when build has secrets' do
        let(:secrets) do
          {
            'DATABASE_PASSWORD' => {
              'vault' => {
                'engine' => { 'name' => 'kv-v2', 'path' => 'kv-v2' },
                'path' => 'production/db',
                'field' => 'password'
              }
            }
          }
        end

        before do
          build.update!(secrets: secrets)
        end

        it 'clones secrets' do
          expect(new_build.secrets).to eq(secrets)
        end
      end
    end
  end
end
