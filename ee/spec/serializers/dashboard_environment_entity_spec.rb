# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DashboardEnvironmentEntity do
  describe '.as_json' do
    it 'includes environment attributes' do
      user = create(:user)
      environment = create(:environment)
      create(:deployment, project: environment.project, environment: environment, status: :success)
      request = EntityRequest.new(current_user: user)

      result = described_class.new(environment, request: request).as_json

      expect(result.keys.sort).to eq([:environment_path, :external_url, :id,
                                      :last_deployment, :last_pipeline, :name])
    end
  end
end
