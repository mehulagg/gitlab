# frozen_string_literal: true

require "spec_helper"

RSpec.describe EE::LockHelper do
  describe '#lock_file_link' do
    let!(:path_lock) { create :path_lock, path: 'app/models' }
    let(:path) { path_lock.path }
    let(:user) { path_lock.user }
    let(:project) { path_lock.project }

    before do
      allow(helper).to receive(:can?).and_return(true)
      allow(helper).to receive(:current_user).and_return(user)
      allow(project).to receive(:feature_available?).with(:file_locks) { true }

      project.reload
    end

    context "there is no locks" do
      it "returns Lock button with no tooltip and correct data attributes for confirm modal" do
        path = '.gitignore'
        result = helper.lock_file_link(project, path, path_type: :file)
        form_data = CGI.escapeHTML({
          path: path
        }.to_json)
        modal_attributes = CGI.escapeHTML({
          title: 'Lock file',
          messageHtml: "Are you sure you want to lock <code>#{path}</code>?",
          size: 'sm',
          okTitle: 'Lock file',
        }.to_json)

        # puts modal_attributes
        # puts result

        expect(result).to match('Lock')
        expect(result).to match('data-method="post"')
        expect(result).to match("data-path=\"#{toggle_project_path_locks_path(project)}\"")
        expect(result).to match("data-form-data=\"#{form_data}\"")
        expect(result).to match(modal_attributes)
      end

      it "returns Lock button with tooltip" do
        allow(helper).to receive(:can?).and_return(false)
        expect(helper.lock_file_link(project, '.gitignore')).to match('You do not have permission to lock this')
      end
    end

    context "exact lock" do
      it "returns Unlock with no tooltip" do
        expect(helper.lock_file_link(project, path)).to match('Unlock')
      end

      it "returns Lock button with tooltip" do
        allow(helper).to receive(:can?).and_return(false)
        expect(helper.lock_file_link(project, path)).to match('Unlock')
        expect(helper.lock_file_link(project, path)).to match("Locked by #{user.name}. You do not have permission to unlock this.")
      end
    end

    context "upstream lock" do
      let(:requested_path) { 'app/models/user.rb' }

      it "returns Lock with no tooltip" do
        expect(helper.lock_file_link(project, requested_path)).to match('Unlock')
        expect(helper.lock_file_link(project, requested_path)).to match(html_escape("#{user.name} has a lock on \"app/models\". Unlock that directory in order to unlock this"))
      end

      it "returns Lock button with tooltip" do
        allow(helper).to receive(:can?).and_return(false)
        expect(helper.lock_file_link(project, requested_path)).to match('Unlock')
        expect(helper.lock_file_link(project, requested_path)).to match(html_escape("#{user.name} has a lock on \"app/models\". You do not have permission to unlock it"))
      end
    end

    context "downstream lock" do
      it "returns Lock with no tooltip" do
        expect(helper.lock_file_link(project, 'app')).to match(html_escape("This directory cannot be locked while #{user.name} has a lock on \"app/models\". Unlock this in order to proceed"))
      end

      it "returns Lock button with tooltip" do
        allow(helper).to receive(:can?).and_return(false)
        expect(helper.lock_file_link(project, 'app')).to match('Lock')
        expect(helper.lock_file_link(project, 'app')).to match(html_escape("This directory cannot be locked while #{user.name} has a lock on \"app/models\". You do not have permission to unlock it"))
      end
    end
  end
end
