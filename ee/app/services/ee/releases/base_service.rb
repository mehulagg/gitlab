# frozen_string_literal: true

module EE
  module Releases
    module BaseService
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        def project_group_id
          project.group&.id
        end
      end
    end
  end
end
