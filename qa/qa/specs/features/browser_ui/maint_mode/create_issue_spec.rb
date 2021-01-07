# frozen_string_literal: true

# module QA
#   RSpec.describe 'Plan', :maint_mode do
#     describe 'Issue creation' do
#       context 'Maintenance Mode enabled' do
#         let(:existing_issue) { #NEED TO PASS IN }

#         before do
#           Flow::Login.sign_in
#         end

#         it 'CANNOT create an issue' do
#           issue = Resource::Issue.fabricate_via_browser_ui!

#           Page::Project::Menu.perform(&:click_issues)

#           Page::Project::Issue::Index.perform do |index|
#             expect(index).not_to have_issue(issue)
#           end
#         end

#         it 'CAN visit an existing issue' do
#           existing_issue.visit!

#           Page::Project::Issue::Show.perform do |issue_page|
#             expect(issue_page).to have_content(existing_issue.title)
#           end

#         end

#         it 'CANNOT close an existing issue' do
#           existing_issue.visit!

#           Page::Project::Issue::Show.perform do |issue_page|
#             issue_page.click_close_issue_button

#             expect(issue_page).to #HAVE MAINTMODE BANNER
#           end

#           Page::Project::Menu.perform(&:click_issues)
#           Page::Project::Issue::Index.perform do |index|
#             expect(index).to have_issue(existing_issue)

#             index.click_closed_issues_link

#             expect(index).not_to have_issue(existing_issue)
#           end
#         end

#         it 'CANNOT edit an existing issue' do
#           existing_issue.visit!
#           # click edit
#           # try to edit
#           # expect maint mode banner and no changes
#         end
#       end
#     end
#   end
# end
