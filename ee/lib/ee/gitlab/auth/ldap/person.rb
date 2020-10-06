# frozen_string_literal: true

require 'net/ldap/dn'

module EE
  module Gitlab
    module Auth
      module Ldap
        module Person
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          class_methods do
            def find_by_email(email, adapter)
              email_attributes = Array(adapter.config.attributes['email'])

              email_attributes.each do |possible_attribute|
                found_user = adapter.user(possible_attribute, email)
                return found_user if found_user
              end

              nil
            end

            def find_by_certificate_issuer_and_serial(issuer_dn, serial, adapter)
              certificate_assertion = "{ serialNumber #{serial}, issuer \"#{issuer_dn}\" }"
              adapter.user_by_certificate_assertion(certificate_assertion)
            end

            def find_by_kerberos_principal(principal, adapter)
              uid, domain = principal.split('@', 2)
              return unless uid && domain
              return unless allowed_realm?(domain, adapter)

              find_by_uid(uid, adapter)
            end

            def allowed_realm?(domain, adapter)
              return domain.casecmp(domain_from_dn(adapter.config.base)) == 0 unless simple_ldap_linking?

              simple_ldap_linking_allowed_realms.select { |realm| domain.casecmp(realm) == 0 }.any?
            end

            def simple_ldap_linking_allowed_realms
              ::Gitlab.config.kerberos.simple_ldap_linking_allowed_realms
            end

            def simple_ldap_linking?
              simple_ldap_linking_allowed_realms.present?
            end

            # Extracts the rightmost unbroken set of domain components from an
            # LDAP DN and constructs a domain name from them
            def domain_from_dn(dn)
              dn_components = []
              ::Gitlab::Auth::Ldap::DN.new(dn).each_pair { |name, value| dn_components << { name: name, value: value } }
              dn_components
                .reverse
                .take_while { |rdn| rdn[:name].casecmp('DC') == 0 } # Domain Component
                .map { |rdn| rdn[:value] }
                .reverse
                .join('.')
            end

            def ldap_attributes(config)
              attributes = super + [
                'memberof',
                (config.sync_ssh_keys if config.sync_ssh_keys.is_a?(String)),
                *config.attributes['first_name'],
                *config.attributes['last_name']
              ]
              attributes.compact.uniq.reject(&:blank?)
            end
          end

          def ssh_keys
            if config.sync_ssh_keys? && entry.respond_to?(config.sync_ssh_keys)
              entry[config.sync_ssh_keys.to_sym]
                .map { |key| key[/(ssh|ecdsa)-[^ ]+ [^\s]+/] }
                .compact
            else
              []
            end
          end

          # We assume that the Kerberos username matches the configured uid
          # attribute in LDAP. For Active Directory, this is `sAMAccountName`
          def kerberos_principal
            return unless uid

            uid + '@' + self.class.domain_from_dn(dn).upcase
          end

          def memberof
            return [] unless entry.attribute_names.include?(:memberof)

            entry.memberof
          end

          def group_cns
            memberof.map { |memberof_value| cn_from_memberof(memberof_value) }
          end

          def cn_from_memberof(memberof)
            # Only get the first CN value of the string, that's the one that contains
            # the group name
            memberof.match(/(?:cn=([\w\s-]+))/i)&.captures&.first
          end

          override :name
          def name
            name = super
            return name if name.present?

            first_name = attribute_value(:first_name)&.first
            last_name = attribute_value(:last_name)&.first
            return unless first_name.present? || last_name.present?

            "#{first_name} #{last_name}".strip
          end
        end
      end
    end
  end
end
