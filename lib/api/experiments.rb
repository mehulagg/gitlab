# frozen_string_literal: true

module API
  class Experiments < Grape::API::Instance
    before { authenticated_as_admin! }

    resource :experiments do
      desc 'Get a list of all experiments' do
        success Entities::Experiment
      end
      get do
        experiments = Gitlab::Experimentation::EXPERIMENTS.keys.each_with_object([]) do |experiment_key, experiment_statuses|
          experiment_statuses << { key: experiment_key, enabled: Gitlab::Experimentation.enabled?(experiment_key) }
        end

        present experiments, with: Entities::Experiment, current_user: current_user
      end
    end
  end
end
