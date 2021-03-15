# frozen_string_literal: true

module EE
  module API
    module Jobs
      extend ActiveSupport::Concern

      prepended do
        resource :job do
          desc 'Get current agents' do
            detail 'Retrieves a list of agents for the given job token'
          end
          route_setting :authentication, job_token_allowed: true
          get '/allowed_agents' do
            status 200

            job = current_authenticated_job

            {
              allowed_agents: find_agents(job.project),
              id: job.id,
              project_id: job.project_id,
              user: {
                id: current_user.id,
                username: current_user.username
              }
            }
          end
        end

        helpers do
          def find_agents(project)
            ::Clusters::AgentsFinder.new(project, current_user).execute.map do |agent|
              {
                id: agent.id,
                config_project: {
                  id: agent.project_id
                }
              }
            end
          end
        end
      end
    end
  end
end
