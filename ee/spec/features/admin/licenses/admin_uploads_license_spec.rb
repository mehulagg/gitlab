# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Admin uploads license", :js do
  let_it_be(:admin) { create(:admin) }

  before do
    sign_in(admin)
    gitlab_enable_admin_mode_sign_in(admin)
  end

  context 'default state' do
    before do
      visit(new_admin_license_path)
    end

    it 'has unselected EULA checkbox by default' do
      expect(page).to have_unchecked_field('accept_eula')
    end

    it 'has disabled button "Upload license" by default' do
      expect(page).to have_button('Upload License', disabled: true)
    end

    it 'redirects to current Subscription terms' do
      expect(page).to have_link('Terms of Service', href: 'https://about.gitlab.com/terms/#subscription')
    end

    it 'enables button "Upload license" when EULA checkbox is selected' do
      expect(page).to have_button('Upload License', disabled: true)

      check('accept_eula')

      expect(page).to have_button('Upload License', disabled: false)
    end
  end

  context "when license key is provided in the query string" do
    before do
      License.destroy_all # rubocop: disable Cop/DestroyAll

      visit(admin_license_path(trial_key: license.data))

      page.within("#modal-upload-trial-license") do
        expect(page).to have_content("Your trial license was issued").and have_button("Install license")
      end

      click_button("Install license")
    end

    context "when license is active immediately" do
      let_it_be(:license) { build(:license, data: build(:gitlab_license, restrictions: { active_user_count: 2000 }).export) }

      it "installs license" do
        expect(page).to have_content("The license was successfully uploaded and is now active")
      end
    end

    context "when license starts in the future" do
      let_it_be(:license) { build(:license, data: build(:gitlab_license, restrictions: { active_user_count: 2000 }, starts_at: Date.current + 1.month).export) }

      it "installs license" do
        expect(page).to have_content("The license was successfully uploaded and will be active from #{license.starts_at}. You can see the details below.")
        .and have_content("You have a license that activates at a future date. Please see the License History table below.")
      end
    end
  end

  context "when license key is not provided in the query string, as it is a repeat trial" do
    before do
      License.destroy_all # rubocop: disable Cop/DestroyAll

      visit(admin_license_path(trial_key: ""))
    end

    it "shows an info banner for repeat trial" do
      expect(page).to have_selector('div#repeat-trial-info')
      expect(page).to have_selector('div.bs-callout-info')
    end
  end

  context "uploading license" do
    before do
      visit(new_admin_license_path)

      File.write(path, license.export)
    end

    context "when license is valid" do
      let_it_be(:path) { Rails.root.join("tmp/valid_license.gitlab-license") }

      context "when license is active immediately" do
        let_it_be(:license) { build(:gitlab_license) }

        it "uploads license" do
          attach_and_upload(path)

          expect(page).to have_content("The license was successfully uploaded and is now active.")
                    .and have_content(license.licensee.each_value.first)
        end
      end

      context "when license starts in the future" do
        let_it_be(:license) { build(:gitlab_license, starts_at: Date.current + 1.month) }

        context "when a current license exists" do
          it "uploads license" do
            attach_and_upload(path)

            expect(page).to have_content("The license was successfully uploaded and will be active from #{license.starts_at}. You can see the details below.")
                      .and have_content(license.licensee.each_value.first)
          end
        end

        context "when no current license exists" do
          before do
            allow(License).to receive(:current).and_return(nil)
          end

          it "uploads license" do
            attach_and_upload(path)

            expect(page).to have_content("The license was successfully uploaded and will be active from #{license.starts_at}. You can see the details below.")
                      .and have_content(license.licensee.each_value.first)
                      .and have_content("You have a license that activates at a future date. Please see the License History table below.")
          end
        end
      end
    end

    context "when license is invalid" do
      let_it_be(:license) { build(:gitlab_license, expires_at: Date.yesterday) }
      let_it_be(:path) { Rails.root.join("tmp/invalid_license.gitlab-license") }

      it "doesn't upload license" do
        attach_and_upload(path)

        expect(page).to have_content("This license has already expired.")
      end
    end
  end

  private

  def attach_and_upload(path)
    attach_file("license_data_file", path)
    check("accept_eula")
    click_button("Upload License")
  end
end
