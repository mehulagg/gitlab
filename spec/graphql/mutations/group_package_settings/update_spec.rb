# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::GroupPackageSettings::Update do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group, reload: true) { create(:group) }
  let_it_be(:user) { create(:user) }

  let(:group_package_setting) { group.group_package_setting }
  let(:params) { { group_path: group.full_path, maven_duplicates_allowed: false, maven_duplicate_exception_regex: 'SNAPSHOT' } }

  specify { expect(described_class).to require_graphql_authorizations(:create_package_settings) }

  describe '#resolve' do
    subject { described_class.new(object: group, context: { current_user: user }, field: nil).resolve(**params) }

    RSpec.shared_examples 'returning a success' do
      it 'returns the group package setting with no errors' do
        expect(subject).to eq(
          group_package_setting: group_package_setting,
          errors: []
        )
      end
    end

    RSpec.shared_examples 'updating the group package setting' do
      it_behaves_like 'updating the group package setting attributes',
        mode: :update,
        from: { maven_duplicates_allowed: true, maven_duplicate_exception_regex: '' },
        to: { maven_duplicates_allowed: false, maven_duplicate_exception_regex: 'SNAPSHOT' }

      it_behaves_like 'returning a success'

      context 'with invalid params' do
        let_it_be(:params) { { group_path: group.full_path, maven_duplicates_allowed: 'foo' } }

        it_behaves_like 'not creating the group package setting'

        it 'doesn\'t update the maven_duplicates_allowed' do
          expect { subject }
            .not_to change { group_package_setting.reload.maven_duplicates_allowed }
        end

        it 'returns an error' do
          expect(subject).to eq(
            group_package_setting: nil,
            errors: ['Maven_duplicates_allowed is not valid']
          )
        end
      end
    end

    RSpec.shared_examples 'denying access to group package setting' do
      it 'raises Gitlab::Graphql::Errors::ResourceNotAvailable' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
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
