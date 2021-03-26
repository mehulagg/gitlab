# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module SecurityCompliance
          module MenuItems
            module Configuration
              extend ::Gitlab::Utils::Override

              override :active_routes
              def active_routes
                super.tap do |params|
                  params[:path] += %w[
                    projects/security/sast_configuration#show
                    projects/security/api_fuzzing_configuration#show
                    projects/security/dast_profiles#show
                    projects/security/dast_site_profiles#new
                    projects/security/dast_site_profiles#edit
                    projects/security/dast_scanner_profiles#new
                    projects/security/dast_scanner_profiles#edit
                  ]
                end
              end
            end
          end
        end
      end
    end
  end
end
