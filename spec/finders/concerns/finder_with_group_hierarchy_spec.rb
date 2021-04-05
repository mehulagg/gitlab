# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FinderWithGroupHierarchy do
  let(:finder_class) do
    Class.new do
      include FinderWithGroupHierarchy
      include Gitlab::Utils::StrongMemoize

      def initialize(current_user, params = {})
        @current_user, @params = current_user, params
      end

      def execute(skip_authorization: false)
        @skip_authorization = skip_authorization

        Label.id_in(item_ids)
      end

      def item_ids
        item_ids = []
        item_ids << Label.where(group_id: group_ids_for(group)) if group?

        item_ids
      end

      private

      attr_reader :current_user, :params, :skip_authorization

      def read_permission
        :read_label
      end
    end
  end

  let_it_be(:group_1) { create(:group) }
  let_it_be(:group_2) { create(:group) }
  let_it_be(:group_3) { create(:group) }
  let_it_be(:private_group_1) { create(:group, :private) }
  let_it_be(:private_subgroup_1) { create(:group, :private, parent: private_group_1) }

  let_it_be(:group_label_1) { create(:group_label, group: group_1, title: 'Label 1 (group)') }
  let_it_be(:group_label_2) { create(:group_label, group: group_1, title: 'Group Label 2') }
  let_it_be(:group_label_3) { create(:group_label, group: group_2, title: 'Group Label 3') }
  let_it_be(:private_group_label_1) { create(:group_label, group: private_group_1, title: 'Private Group Label 1') }
  let_it_be(:private_subgroup_label_1) { create(:group_label, group: private_subgroup_1, title: 'Private Sub Group Label 1') }

  let_it_be(:unused_group_label) { create(:group_label, group: group_3, title: 'Group Label 4') }
  let_it_be(:user) { create(:user) }

  let(:user) { create(:user) }

  subject(:finder) { finder_class.new(user) }

  def expect_access_check_on_result
    expect(finder).not_to receive(:requires_access?)
    expect(Ability).to receive(:allowed?).with(user, :read_issue, result).and_call_original
  end

  context 'when including items from group ancestors' do
    it 'returns items from group and its ancestors' do
      private_group_1.add_developer(user)
      private_subgroup_1.add_developer(user)

      finder = finder_class.new(user, group: private_subgroup_1, include_ancestor_groups: true)

      expect(finder.execute).to match_array([private_group_label_1, private_subgroup_label_1])
    end

    it 'ignores labels from groups which user can not read' do
      private_subgroup_1.add_developer(user)

      finder = finder_class.new(user, group: private_subgroup_1, include_ancestor_groups: true)

      expect(finder.execute).to match_array([private_subgroup_label_1])
    end
  end

  context 'when including items from group descendants' do
    it 'returns items from group and its descendants' do
      private_group_1.add_developer(user)
      private_subgroup_1.add_developer(user)

      finder = finder_class.new(user, group: private_group_1, include_descendant_groups: true)

      expect(finder.execute).to match_array([private_group_label_1, private_subgroup_label_1])
    end

    it 'ignores items from groups which user can not read' do
      private_subgroup_1.add_developer(user)

      finder = finder_class.new(user, group: private_group_1, include_descendant_groups: true)

      expect(finder.execute).to match_array([private_subgroup_label_1])
    end
  end

  # context 'when the user cannot read cross project' do
  #   before do
  #     allow(Ability).to receive(:allowed?).and_call_original
  #     allow(Ability).to receive(:allowed?).with(user, :read_cross_project)
  #                                         .and_return(false)
  #   end
  #
  #   describe '#execute' do
  #     it 'returns a issue if the check is disabled' do
  #       expect(finder).to receive(:requires_access?).and_return(false)
  #
  #       expect(finder.execute).to include(result)
  #     end
  #
  #     it 'returns an empty relation when the check is enabled' do
  #       expect(finder).to receive(:requires_access?).and_return(true)
  #
  #       expect(finder.execute).to be_empty
  #     end
  #
  #     it 'only queries once when check is enabled' do
  #       expect(finder).to receive(:requires_access?).and_return(true)
  #
  #       expect { finder.execute }.not_to exceed_query_limit(1)
  #     end
  #
  #     it 'only queries once when check is disabled' do
  #       expect(finder).to receive(:requires_access?).and_return(false)
  #
  #       expect { finder.execute }.not_to exceed_query_limit(1)
  #     end
  #   end
  #
  #   describe '#find' do
  #     it 'checks the accessibility of the subject directly' do
  #       expect_access_check_on_result
  #
  #       finder.find(result.id)
  #     end
  #
  #     it 'returns the issue' do
  #       expect(finder.find(result.id)).to eq(result)
  #     end
  #   end
  #
  #   describe '#find_by' do
  #     it 'checks the accessibility of the subject directly' do
  #       expect_access_check_on_result
  #
  #       finder.find_by(id: result.id)
  #     end
  #   end
  #
  #   describe '#find_by!' do
  #     it 'checks the accessibility of the subject directly' do
  #       expect_access_check_on_result
  #
  #       finder.find_by!(id: result.id)
  #     end
  #
  #     it 're-enables the check after the find failed' do
  #       finder.find_by!(id: non_existing_record_id) rescue ActiveRecord::RecordNotFound
  #
  #       expect(finder.instance_variable_get(:@should_skip_cross_project_check))
  #         .to eq(false)
  #     end
  #   end
  # end
  #
  # context 'when the user can read cross project' do
  #   before do
  #     allow(Ability).to receive(:allowed?).and_call_original
  #     allow(Ability).to receive(:allowed?).with(user, :read_cross_project)
  #                                         .and_return(true)
  #   end
  #
  #   it 'returns the result' do
  #     expect(finder).not_to receive(:requires_access?)
  #
  #     expect(finder.execute).to include(result)
  #   end
  # end
  #
  # context 'when specifying a model' do
  #   let(:finder_class) do
  #     Class.new do
  #       prepend FinderWithCrossProjectAccess
  #
  #       requires_cross_project_access model: Project
  #     end
  #   end
  #
  #   describe '.finder_model' do
  #     it 'is set correctly' do
  #       expect(finder_class.finder_model).to eq(Project)
  #     end
  #   end
  # end
end
