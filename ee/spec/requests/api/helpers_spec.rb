# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Helpers do
  include API::APIGuard::HelperMethods
  include described_class

  let_it_be(:user) { create(:user) }
  let(:route_authentication_setting) { {} }
  let(:csrf_token) { SecureRandom.base64(ActionController::RequestForgeryProtection::AUTHENTICITY_TOKEN_LENGTH) }
  let(:env) do
    {
      'rack.input' => '',
      'rack.session' => {
        _csrf_token: csrf_token
      },
      'REQUEST_METHOD' => 'GET',
      'CONTENT_TYPE' => 'text/plain;charset=utf-8'
    }
  end

  let(:header) { }
  let(:request) { Grape::Request.new(env)}
  let(:params) { request.params }

  def error!(message, status, header)
    raise StandardError.new("#{status} - #{message}")
  end

  before do
    allow_any_instance_of(self.class).to receive(:options).and_return({})
    allow_any_instance_of(self.class).to receive(:route_authentication_setting)
      .and_return(route_authentication_setting)
  end

  describe ".current_user" do
    describe "when authenticating using a job token" do
      let_it_be(:job, reload: true) do
        create(:ci_build, user: user, status: :running)
      end

      context 'when route is allowed to be authenticated' do
        let(:route_authentication_setting) { { job_token_allowed: true } }

        it "returns a 401 response for an invalid token" do
          env[Gitlab::Auth::AuthFinders::JOB_TOKEN_HEADER] = 'invalid token'

          expect { current_user }.to raise_error /401/
        end

        it "returns a 401 response for a job that's not running" do
          job.update!(status: :success)
          env[Gitlab::Auth::AuthFinders::JOB_TOKEN_HEADER] = job.token

          expect { current_user }.to raise_error /401/
        end

        it "returns a 403 response for a user without access" do
          env[Gitlab::Auth::AuthFinders::JOB_TOKEN_HEADER] = job.token
          allow_any_instance_of(Gitlab::UserAccess).to receive(:allowed?).and_return(false)

          expect { current_user }.to raise_error /403/
        end

        it 'returns a 403 response for a user who is blocked' do
          user.block!
          env[Gitlab::Auth::AuthFinders::JOB_TOKEN_HEADER] = job.token

          expect { current_user }.to raise_error /403/
        end

        it "sets current_user" do
          env[Gitlab::Auth::AuthFinders::JOB_TOKEN_HEADER] = job.token

          expect(current_user).to eq(user)
        end
      end

      context 'when route is not allowed to be authenticated' do
        let(:route_authentication_setting) { { job_token_allowed: false } }

        it "sets current_user to nil" do
          env[Gitlab::Auth::AuthFinders::JOB_TOKEN_HEADER] = job.token
          allow_any_instance_of(Gitlab::UserAccess).to receive(:allowed?).and_return(true)

          expect(current_user).to be_nil
        end
      end
    end
  end
end
