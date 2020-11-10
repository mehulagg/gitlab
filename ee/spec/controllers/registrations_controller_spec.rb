# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RegistrationsController do
  let_it_be(:user) { create(:user) }

  describe '#create' do
    let(:base_user_params) { build_stubbed(:user).slice(:first_name, :last_name, :username, :email, :password) }
    let(:user_params) { { user: base_user_params } }

    context 'when reCAPTCHA experiment enabled' do
      it "logs a 'User Created' message including the experiment state" do
        allow_any_instance_of(EE::RecaptchaExperimentHelper).to receive(:show_recaptcha_sign_up?).and_return(true)

        expect(Gitlab::AppLogger).to receive(:info).with(/\AUser Created: .+experiment_growth_recaptcha\?true\z/).and_call_original

        post :create, params: user_params
      end
    end
  end
end
