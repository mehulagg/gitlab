# frozen_string_literal: true

module Environments
  module CanaryIngress
    class PatchService < ::BaseService
      include Gitlab::ExclusiveLeaseHelpers

      attr_reader :environment

      def execute(environment)
        @environment = environment

        in_lock(lock_key, retries: 0) do
          unsafe_update
        end
      end

      private

      def unsafe_update
        canary_ingress = environment.ingresses&.find(&:canary?)

        unless canary_ingress.present?
          return error(_('Canary Ingress does not exist in the environment.'))
        end

        if environment.patch_ingress(canary_ingress, patch_data)
          success
        else
          error(_('Failed to update the Canary Ingress.'), :bad_request)
        end
      end

      def lock_key
        "environments:canary_ingress:patch_service:lock:#{environment.id}"
      end

      def patch_data
        {
          metadata: {
            annotations: {
              Gitlab::Kubernetes::Ingress::ANNOTATION_KEY_CANARY_WEIGHT => params[:weight].to_s
            }
          }
        }
      end
    end
  end
end
