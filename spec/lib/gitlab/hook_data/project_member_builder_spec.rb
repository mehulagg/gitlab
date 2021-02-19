# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::HookData::ProjectMemberBuilder do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:project_member) { create(:project_member, :developer, user: user, project: project) }

  describe '#build' do
    let(:data) { described_class.new(project_member).build(event) }
    let(:event_name) { data[:event_name] }
    let(:attributes) do
      [
        :event_name, :created_at, :updated_at, :project_name, :project_path, :project_path_with_namespace, :project_id, :user_username, :user_name, :user_email, :user_id, :access_level, :project_visibility
      ]
    end

    context 'data' do
      shared_examples_for 'includes the required attributes' do
        it 'includes the required attributes' do
          expect(data).to include(*attributes)

          expect(data[:project_name]).to eq(project.name)
          expect(data[:project_path]).to eq(project.path)
          expect(data[:project_path_with_namespace]).to eq(project.full_path)
          expect(data[:project_id]).to eq(project.id)
          expect(data[:user_username]).to eq(project_member.user.username)
          expect(data[:user_name]).to eq(project_member.user.name)
          expect(data[:user_id]).to eq(project_member.user.id)
          expect(data[:user_email]).to eq(project_member.user.email)
          expect(data[:access_level]).to eq(project_member.human_access)
          expect(data[:project_visibility]).to eq(Project.visibility_levels.key(project.visibility_level_value).downcase)
        end
      end

      context 'on create' do
        let(:event) { :create }

        it { expect(event_name).to eq('user_add_to_team') }
        it_behaves_like 'includes the required attributes'
      end

      context 'on update' do
        let(:event) { :update }

        it { expect(event_name).to eq('user_update_for_team') }
        it_behaves_like 'includes the required attributes'
      end

      context 'on destroy' do
        let(:event) { :destroy }

        it { expect(event_name).to eq('user_remove_from_team') }
        it_behaves_like 'includes the required attributes'
      end
    end
  end
end
