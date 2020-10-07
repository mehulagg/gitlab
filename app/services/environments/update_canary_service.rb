# frozen_string_literal: true

module Environments
  class UpdateCanaryService < ::BaseService
    attr_reader :canary_ingress

    def execute(environment)
      result = validate(environment)

      return result unless result[:status] == :success

      environment.patch_ingress(canary_ingress, new_annotation)

      if result[:status] == :success
        success(environment: environment)
      else
        error(environment.errors.full_messages.join(','), http_status: :bad_request)
      end
    end

    private

    def new_annotation
      {
        metadata: {
          annotations: {
            key: Gitlab::Kubernetes::Ingress::ANNOTATION_KEY_CANARY_WEIGHT,
            value: params[:weight]
          }
        }
      }
    end

    def validate(environment)
      unless Feature.enabled?(:canary_ingress_weight_control, project)
        return error(_('Feature flag is not enabled on this project.'))
      end

      unless environment.project.feature_avaliable?(:deploy_board)
        return error(_('The license for Deploy Board is required to use this feature.'))
      end

      unless can_update_environment?(environment)
        return error(_('You do not have permission to update the environment.'))
      end

      unless params[:weight] && (0..100).include?(params[:weight].to_i)
        return error(_('Canary weight must be specified and valid range (0..100)'))
      end

      if environment.has_running_deployments?
        return error(_('There are running deployments on the environment. Please retry later.'))
      end

      unless @canary_ingress = environment.get_ingresses.find(&:canary?)
        return error(_('Canary Ingress does not exist in the environment'))
      end

      success
    end

    def can_update_environment?(environment)
      can?(current_user, :update_environment, environment)
    end

    def ci_yaml
      {
        stages: %w[update],
        JOB_NAME => {
          image: AUTO_DEPLOY_IMAGE,
          scripts: ["auto-deploy download_chart",
                    "auto-deploy scale canary #{params[:weight]}"],
          environment: {
            name: environment.name,
            action: :prepare
          }
        }
      }.to_yaml
    end
  end
end
