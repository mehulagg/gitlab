# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuablesDescriptionTemplatesHelper do
  include_context 'project issuable templates context'

  describe '#issuable_templates' do
    context 'when project parent group has a file template project' do
      let_it_be(:user) { create(:user) }
      let_it_be_with_reload(:parent_group) { create(:group) }
      let_it_be_with_reload(:group) { create(:group, parent: parent_group) }
      let_it_be_with_reload(:project) { create(:project, :custom_repo, group: group, files: issuable_template_files) }
      let_it_be(:file_template_project) { create(:project, :custom_repo, group: parent_group, files: issuable_template_files) }
      let_it_be(:group_member) { create(:group_member, :developer, group: parent_group, user: user) }
      let_it_be(:inherited_from) { file_template_project }

      before do
        stub_licensed_features(custom_file_templates_for_namespace: true)

        parent_group.update_columns(file_template_project_id: file_template_project.id)
      end

      it_behaves_like 'project issuable templates'
    end
  end
end
