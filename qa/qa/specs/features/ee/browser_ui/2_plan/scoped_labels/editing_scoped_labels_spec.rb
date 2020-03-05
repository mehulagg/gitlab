# frozen_string_literal: true

module QA
  context 'Plan', :reliable do
    describe 'Editing scoped labels on issues' do
      let(:initial_label) { 'animal::fox' }
      let(:new_label_same_scope) { 'animal::dolphin' }
      let(:new_label_different_scope) { 'plant::orchid' }

      let(:initial_label_multi_colon) { 'group::car::ferrari' }
      let(:new_label_same_scope_multi_colon) { 'group::car::porsche' }
      let(:new_label_different_scope_multi_colon) { 'group::truck::mercedes-bens' }

      before do
        Flow::Login.formless_login
        # Flow::Login.sign_in

        issue = Resource::Issue.fabricate_via_api! do |issue|
          issue.labels = [initial_label, initial_label_multi_colon]
        end

        [
          new_label_same_scope,
          new_label_different_scope,
          new_label_same_scope_multi_colon,
          new_label_different_scope_multi_colon
        ].each do |label|
          Resource::Label.fabricate_via_api! do |l|
            l.project = issue.project
            l.title = label
          end
        end

        issue.visit!
      end

      it 'correctly applies simple and multiple colon scoped pairs labels' do
        Page::Project::Issue::Show.perform do |show|
          show.select_labels_and_refresh([
            new_label_same_scope,
            new_label_different_scope,
            new_label_same_scope_multi_colon,
            new_label_different_scope_multi_colon
          ])

          show.select_all_activities_filter

          expect(show.text_of_labels_block).to have_content(new_label_same_scope.gsub('::', ' '))
          expect(show.text_of_labels_block).to have_content(new_label_different_scope.gsub('::', ' '))
          expect(show.text_of_labels_block).to have_content('group::car porsche')
          expect(show.text_of_labels_block).to have_content('group::truck mercedes-bens')

          expect(show.text_of_labels_block).not_to have_content(initial_label.gsub('::', ' '))
          expect(show.text_of_labels_block).not_to have_content('group::car ferrari')
        end
      end
    end
  end
end
