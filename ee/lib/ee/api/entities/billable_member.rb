# frozen_string_literal: true

module EE
  module API
    module Entities
      class BillableMember < ::API::Entities::UserBasic
        expose :public_email, as: :email
        expose :last_activity_on
      end
    end
  end
end
