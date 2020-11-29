# frozen_string_literal: true

module API
  class Experiments < ::API::Base
    before { authorize_read_experiments! }

    feature_category :product_analytics

    resource :experiments do
      desc 'Get a list of all experiments' do
        success EE::API::Entities::Experiment
      end
      get do
        experiments = Gitlab::Experimentation::EXPERIMENTS.keys.map do |experiment_key|
          { key: experiment_key, enabled: Gitlab::Experimentation.enabled?(experiment_key) }
        end

        present experiments, with: EE::API::Entities::Experiment, current_user: current_user
      end
    end

    helpers do
      def authorize_read_experiments!
        authenticate!

        forbidden! unless current_user.gitlab_team_member?
      end
    end
  end
end
