# frozen_string_literal: true

module EE
  module Preloaders
    module LabelsPreloader
      extend ::Gitlab::Utils::Override

      override :preload_all
      def preload_all
        super

        preloader = ActiveRecord::Associations::Preloader.new
        preloader.preload(labels.select { |l| l.is_a? GroupLabel }, { group: [:ip_restrictions, :saml_provider] })
      end
    end
  end
end
