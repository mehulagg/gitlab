# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ResourceAccessTokens::RevokeService do
  subject { described_class.new(user, resource, access_token).execute }

  let_it_be(:user) { create(:user) }
  let(:access_token) { create(:personal_access_token, user: resource_bot) }

  describe '#execute' do
    # Created shared_examples as it will easy to include specs for group bots in https://gitlab.com/gitlab-org/gitlab/-/issues/214046
    shared_examples 'revokes access token' do
      it { expect(subject.success?).to be true }

      it { expect(subject.message).to eq("Revoked access token: #{access_token.name}") }

      it 'removes membership of bot user' do
        subject

        expect(resource.reload.users).not_to include(resource_bot)
      end

      it 'transfer issuables of bot user to ghost user' do
        issue = create(:issue, author: resource_bot)

        subject

        expect(issue.reload.author.ghost?).to be true
      end

      it 'destroys project bot user' do
        subject

        expect(User.exists?(resource_bot.id)).to be_falsy
      end
    end

    shared_examples 'rollback revoke steps' do
      it 'does not revoke the access token' do
        subject

        expect(access_token.reload.revoked?).to be false
      end

      it 'does not remove bot from member list' do
        subject

        expect(resource.reload.users).to include(resource_bot)
      end

      it 'does not transfer issuables of bot user to ghost user' do
        issue = create(:issue, author: resource_bot)

        subject

        expect(issue.reload.author.ghost?).to be false
      end

      it 'does not destroy project bot user' do
        subject

        expect(User.exists?(resource_bot.id)).to be_truthy
      end
    end

    context 'when resource is a project' do
      let_it_be(:resource) { create(:project, :private) }
      let(:resource_bot) { create(:user, :project_bot) }

      before do
        resource.add_maintainer(user)
        resource.add_maintainer(resource_bot)
      end

      it_behaves_like 'revokes access token'

      context 'revoke fails' do
        let_it_be(:outside_user) { create(:user) }
        let_it_be(:outside_access_token) { create(:personal_access_token, user: outside_user) }
        let_it_be(:developer) { create(:user) }

        context 'when access token does not belong to this project' do
          subject { described_class.new(user, resource, outside_access_token).execute }

          it 'does not find the bot' do
            response = subject

            expect(response.success?).to be false
            expect(response.message).to eq("Failed to find bot user")
            expect(access_token.reload.revoked?).to be false
          end
        end

        context 'when user does not have permission to destroy bot' do
          context 'when non-project member tries to delete project bot' do
            subject { described_class.new(outside_user, resource, access_token).execute }

            it 'does not allow outside user to delete bot' do
              response = subject

              expect(response.success?).to be false
              expect(response.message).to eq("#{outside_user.name} cannot delete #{access_token.user.name}")
              expect(access_token.reload.revoked?).to be false
            end
          end

          context 'when non-maintainer project member tries to delete project bot' do
            subject { described_class.new(developer, resource, access_token).execute }

            before do
              resource.add_developer(developer)
            end

            it 'does not allow developer to delete bot' do
              response = subject

              expect(response.success?).to be false
              expect(response.message).to eq("#{developer.name} cannot delete #{access_token.user.name}")
              expect(access_token.reload.revoked?).to be false
            end
          end
        end

        context 'when migration to ghost user fails' do
          before do
            allow_next_instance_of(::Members::DestroyService) do |service|
              allow(service).to receive(:execute).and_return(false)
            end
          end

          it_behaves_like 'rollback revoke steps'
        end

        context 'when bot deletion fails' do
          before do
            allow_next_instance_of(::Users::DestroyService) do |service|
              allow(service).to receive(:execute).and_return(false)
            end
          end

          it_behaves_like 'rollback revoke steps'
        end
      end
    end
  end
end
