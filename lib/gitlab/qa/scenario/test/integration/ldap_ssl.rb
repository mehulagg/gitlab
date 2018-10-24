require 'yaml'

module Gitlab
  module QA
    module Scenario
      module Test
        module Integration
          class LDAPSSL < LDAP
            def initialize
              @gitlab_name = 'gitlab'
              @spec_suite = 'Test::Integration::LDAPSSL'
              @tls = true
            end

            def configure(gitlab, ldap)
              ldap.set_accept_insecure_certs
              gitlab.omnibus_config = <<~OMNIBUS
                    gitlab_rails['ldap_enabled'] = true;
                    gitlab_rails['ldap_servers'] = #{ldap.to_config};
                    letsencrypt['enable'] = false;
                    external_url '#{gitlab.address}';
              OMNIBUS
            end
          end
        end
      end
    end
  end
end
