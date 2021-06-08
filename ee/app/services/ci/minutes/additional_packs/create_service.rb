# frozen_string_literal: true

module Ci
  module Minutes
    module AdditionalPacks
      class CreateService
        include BaseServiceUtility

        attr_reader :current_user, :namespace, :purchase_xid, :expires_at, :number_of_minutes

        def initialize(current_user, namespace, params = {})
          @current_user = current_user
          @namespace = namespace
          @purchase_xid = params[:purchase_xid]
          @expires_at = params[:expires_at]
          @number_of_minutes = params[:number_of_minutes]
        end

        def execute
          raise Gitlab::Access::AccessDeniedError unless current_user.can_admin_all_resources?

          return successful_response if additional_pack.persisted?

          save_additional_pack ? successful_response : error_response
        end

        private

        # rubocop: disable CodeReuse/ActiveRecord
        def additional_pack
          @additional_pack ||= Ci::Minutes::AdditionalPack.find_or_initialize_by(
            namespace: namespace,
            purchase_xid: purchase_xid
          )
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def save_additional_pack
          additional_pack.assign_attributes(
            expires_at: expires_at,
            number_of_minutes: number_of_minutes,
            purchase_xid: purchase_xid
          )

          additional_pack.save
        end

        def successful_response
          success({ additional_pack: additional_pack })
        end

        def error_response
          error(
            'Unable to save additional pack',
            422,
            pass_back: { errors: additional_pack.errors })
        end
      end
    end
  end
end
