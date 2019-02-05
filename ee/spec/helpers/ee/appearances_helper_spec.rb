require 'spec_helper'

describe AppearancesHelper do
  before do
    user = create(:user)
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe '#header_message' do
    it 'returns nil when header message field is not set' do
      create(:appearance)

      expect(helper.header_message).to be_nil
    end

    context 'when header message is set' do
      it 'returns nil when unlicensed' do
        create(:appearance, header_message: "Foo bar")

        stub_licensed_features(system_header_footer: false)

        expect(helper.header_message).to be_nil
      end

      it 'includes current message when licensed' do
        message = "Foo bar"
        create(:appearance, header_message: message)

        stub_licensed_features(system_header_footer: true)

        expect(helper.header_message).to include(message)
      end
    end
  end

  describe '#footer_message' do
    it 'returns nil when footer message field is not set' do
      create(:appearance)

      expect(helper.footer_message).to be_nil
    end

    context 'when footer message is set' do
      it 'returns nil when unlicensed' do
        create(:appearance, footer_message: "Foo bar")

        stub_licensed_features(system_header_footer: false)

        expect(helper.footer_message).to be_nil
      end

      it 'includes current message when licensed' do
        message = "Foo bar"
        create(:appearance, footer_message: message)

        stub_licensed_features(system_header_footer: true)

        expect(helper.footer_message).to include(message)
      end
    end
  end

  describe '#brand_image' do
    let!(:appearance) { create(:appearance, :with_logo) }

    context 'when there is a logo' do
      it 'returns a path' do
        expect(helper.brand_image).to match(%r(img data-src="/uploads/-/system/appearance/.*png))
      end
    end

    context 'when there is a logo but no associated upload' do
      before do
        # Legacy attachments were not tracked in the uploads table
        appearance.logo.upload.destroy
        appearance.reload
      end

      it 'falls back to using the original path' do
        expect(helper.brand_image).to match(%r(img data-src="/uploads/-/system/appearance/.*png))
      end
    end
  end

  describe '#brand_title' do
    it 'returns the default EE title when no appearance is present' do
      allow(helper)
        .to receive(:current_appearance)
        .and_return(nil)

      expect(helper.brand_title).to eq('GitLab Enterprise Edition')
    end
  end
end
