# frozen_string_literal: true

module EE
  module Gitlab
    module GonHelper
      extend ::Gitlab::Utils::Override

      override :add_gon_variables
      def add_gon_variables
        super

        gon.roadmap_epics_limit = 1000
      end
    end
  end
end
