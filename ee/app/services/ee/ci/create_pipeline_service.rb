# frozen_string_literal: true

module EE
  module Ci
    module CreatePipelineService
      extend ::Gitlab::Utils::Override

      override :extra_options
      def extra_options(mirror_update: false, **options)
        options.merge(allow_mirror_update: mirror_update)
      end
    end
  end
end
