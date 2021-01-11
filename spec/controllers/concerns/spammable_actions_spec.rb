# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpammableActions do
  controller(ActionController::Base) do
    include SpammableActions

    # #create is used to test spammable_params
    def create
      spam_params = spammable_params

      # replace the actual request with a string in the JSON response, all we care is that it got set
      spam_params[:request] = 'this is the request' if spam_params[:request]

      # just return the params in the response so they can be verified in this fake controller spec.
      # Normally, they are processed further by the controller action
      render json: spam_params.to_json, status: :ok
    end

    # #update is used to test recaptcha_check_with_fallback
    def update
      should_redirect = params[:should_redirect] == 'true'

      recaptcha_check_with_fallback(should_redirect) { render json: :ok }
    end

    # public method so we can use it from the specs
    def spammable
      # make a fake spammable, which has a #valid? method controlled by the #spammable_is_valid param
      OpenStruct.new(valid?: params[:spammable_is_valid] == 'true')
    end

    private

    def spammable_path
      '/fake_spammable_path'
    end
  end

  describe '#spammable_params' do
    subject { post :create, format: :json, params: params }

    shared_examples 'expects request param only' do
      it do
        subject

        expect(response).to be_successful
        expect(json_response).to eq({ 'request' => 'this is the request' })
      end
    end

    shared_examples 'expects all spammable params' do
      let(:spam_log_id) { 1 }

      it do
        subject

        expect(response).to be_successful
        expect(json_response['request']).to eq('this is the request')
        expect(json_response['recaptcha_verified']).to eq(true)
        expect(json_response['spam_log_id']).to eq("1")
      end
    end

    let(:recaptcha_verification) { nil }
    let(:spam_log_id) { nil }
    let(:verify_spammable_recaptcha_mock_return_value) { nil }
    let(:params) do
      {
        recaptcha_verification: recaptcha_verification,
        spam_log_id: spam_log_id,
        verify_spammable_recaptcha_mock_return_value: verify_spammable_recaptcha_mock_return_value
      }
    end

    context 'when recaptcha_verification is not present' do
      it_behaves_like 'expects request param only'
    end

    context 'when recaptcha_verification is present' do
      let(:recaptcha_verification) { true }

      context 'when verify_spammable_recaptcha! returns falsy' do
        it_behaves_like 'expects request param only'
      end

      context 'when verify_spammable_recaptcha! returns truthy' do
        before do
          # no args currently are passed to :verify_spammable_recaptcha by spammable_actions
          expect(controller).to receive(:verify_spammable_recaptcha!).with(no_args) { true }
        end

        it_behaves_like 'expects all spammable params'
      end
    end
  end

  describe '#recaptcha_check_with_fallback' do
    let(:format) { :html }

    subject { post :update, format: format, params: params }

    let(:should_redirect) { nil }
    let(:spammable_is_valid) { nil }
    let(:recaptcha_verification) { nil }
    let(:params) do
      {
        should_redirect: should_redirect,
        spammable_is_valid: spammable_is_valid,
        recaptcha_verification: recaptcha_verification
      }
    end

    before do
      routes.draw { get 'update' => 'anonymous#update' }
    end

    context 'when should_redirect is true and spammable is valid' do
      let(:should_redirect) { true }
      let(:spammable_is_valid) { true }

      it 'redirects to spammable_path' do
        expect(subject).to redirect_to('/fake_spammable_path')
      end
    end

    context 'when should_redirect is false or spammable is not valid' do
      context 'when render_recaptcha?(spammable) is true' do
        before do
          expect(controller).to receive(:render_recaptcha?).with(controller.spammable) { true }
        end

        context 'when params[:recaptcha_verification] is true' do
          let(:recaptcha_verification) { true }

          it 'flashes alert' do
            allow(controller).to receive(:render).with(:verify)

            subject

            expect(response).to set_flash[:alert].to(/There was an error with the reCAPTCHA/i)
          end
        end

        context 'when format is :html' do
          it 'renders :verify' do
            expect(controller).to receive(:render).with(:verify)

            subject
          end
        end

        context 'when format is :json' do
          let(:format) { :json }
          let(:recaptcha_html) { '<recaptcha-html/>' }

          it 'renders json with recaptcha_html' do
            expect(controller).to receive(:render_to_string).with(
              {
                partial: 'shared/recaptcha_form',
                formats: :html,
                locals: {
                  spammable: controller.spammable,
                  script: false,
                  has_submit: false
                }
              }
            ) { recaptcha_html }

            subject

            expect(json_response).to eq({ 'recaptcha_html' => recaptcha_html })
          end
        end
      end
    end
  end
end
