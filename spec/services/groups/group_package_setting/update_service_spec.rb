# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Groups::GroupPackageSetting::UpdateService do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group, reload: true) { create(:group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:params) { { maven_duplicates_allowed: false, maven_duplicate_exception_regex: 'SNAPSHOT' } }

  let(:group_package_setting) { group.group_package_setting }

  describe '#execute' do
    subject { described_class.new(group, user, params).execute }

    RSpec.shared_examples 'returning a success' do
      it 'returns a success' do
        result = subject

        expect(result.payload[:group_package_setting]).to be_present
        expect(result.success?).to be_truthy
      end
    end

    RSpec.shared_examples 'returning an error' do |message, http_status|
      it 'returns an error' do
        result = subject

        expect(result.message).to eq(message)
        expect(result.status).to eq(:error)
        expect(result.http_status).to eq(http_status)
      end
    end

    RSpec.shared_examples 'updating the group package setting' do
      it_behaves_like 'updating the group package setting attributes', mode: :update, from: { maven_duplicates_allowed: true, maven_duplicate_exception_regex: '' }, to: { maven_duplicates_allowed: false, maven_duplicate_exception_regex: 'SNAPSHOT' }

      it_behaves_like 'returning a success'

      context 'with invalid params' do
        let_it_be(:params) { { maven_duplicates_allowed: nil } }

        it_behaves_like 'not creating the group package setting'

        it "doesn't update the maven_duplicates_allowed" do
          expect { subject }
            .not_to change { group_package_setting.reload.maven_duplicates_allowed }
        end

        it_behaves_like 'returning an error', 'Maven duplicates allowed is not included in the list', 400
      end
    end

    RSpec.shared_examples 'denying access to group package setting' do
      context 'with existing group package setting' do
        it_behaves_like 'not creating the group package setting'

        it_behaves_like 'returning an error', 'Access Denied', 403
      end
    end

    context 'with existing group package setting' do
      where(:user_role, :shared_examples_name) do
        :maintainer | 'updating the group package setting'
        :developer  | 'updating the group package setting'
        :reporter   | 'denying access to group package setting'
        :guest      | 'denying access to group package setting'
        :anonymous  | 'denying access to group package setting'
      end

      with_them do
        before do
          group.send("add_#{user_role}", user) unless user_role == :anonymous
        end

        it_behaves_like params[:shared_examples_name]
      end
    end

    context 'without existing group package setting' do
      let_it_be(:group, reload: true) { create(:group, :without_group_package_setting) }

      where(:user_role, :shared_examples_name) do
        :maintainer | 'creating the group package setting'
        :developer  | 'creating the group package setting'
        :reporter   | 'denying access to group package setting'
        :guest      | 'denying access to group package setting'
        :anonymous  | 'denying access to group package setting'
      end

      with_them do
        before do
          group.send("add_#{user_role}", user) unless user_role == :anonymous
        end

        it_behaves_like params[:shared_examples_name]
      end
    end
  end
end
