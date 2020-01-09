# frozen_string_literal: true

module QA
  context 'Plan' do
    describe 'Configurable issue board' do
      let(:label_board_list) do
        EE::Resource::Board::BoardList::Project::LabelBoardList.fabricate_via_api!
      end

      before do
        Flow::Login.sign_in
        label_board_list.project.visit!
        Page::Project::Menu.perform(&:go_to_boards)
      end

      it 'renames the issue board' do
        new_board_name = 'UX'

        EE::Page::Component::IssueBoard::Show.perform do |show|
          show.click_boards_config_button

          show.set_name(new_board_name)

          expect(show.boards_dropdown).to have_content(new_board_name)
        end
      end
    end
  end
end
