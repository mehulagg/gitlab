require 'securerandom'

# This component sets up the docker-openldap (https://github.com/osixia/docker-openldap)
# image with the proper configuration for GitLab users to login.
#
# By default, the docker-openldap image configures the Docker image with a
# default admin user in the example.org domain. This user does not have a uid
# attribute that GitLab needs to authenticate, so we seed the LDAP server with
# a "tanuki" user via a LDIF file in the fixtures/ldap directory.
#
# The docker-openldap container has a startup script
# (https://github.com/osixia/docker-openldap/blob/v1.1.11/image/service/slapd/startup.sh#L74-L78)
# that looks for custom LDIF files in the BOOTSTRAP_LDIF directory. Note that the LDIF
# files must have a "changetype" option specified for the script to work.
module Gitlab
  module QA
    module Component
      class LDAP
        include Scenario::Actable

        LDAP_IMAGE = 'osixia/openldap'.freeze
        LDAP_IMAGE_TAG = 'latest'.freeze
        LDAP_DOMAIN = 'example.org'.freeze
        ADMIN_USER = 'admin'.freeze
        ADMIN_PASSWORD = 'admin'.freeze
        LDAP_USER = 'tanuki'.freeze
        LDAP_PASSWORD = 'password'.freeze
        LDAP_PORT = 389
        LDAP_TLS_PORT = 636
        BASE_DN = 'dc=example,dc=org'.freeze
        BIND_DN = 'cn=admin,dc=example,dc=org'.freeze
        BOOTSTRAP_LDIF = '/container/service/slapd/assets/config/bootstrap/ldif/custom'.freeze
        GROUP_BASE = 'ou=groups,dc=example,dc=org'.freeze
        ADMIN_GROUP = 'admin'.freeze
        FIXTURE_PATH = File.expand_path('../../../../fixtures/ldap'.freeze, __dir__)

        attr_reader :docker
        attr_accessor :volumes, :network, :environment
        attr_writer :name

        def initialize
          @docker = Docker::Engine.new
          @environment = {}
          @volumes = {}
          @network_aliases = []

          @volumes[FIXTURE_PATH] = BOOTSTRAP_LDIF
        end

        # LDAP_TLS is true by default
        def tls=(status)
          if status
            @environment['LDAP_TLS_CRT_FILENAME'] = "#{hostname}.crt"
            @environment['LDAP_TLS_KEY_FILENAME'] = "#{hostname}.key"
            @environment['LDAP_TLS_ENFORCE'] = 'true'
            @environment['LDAP_TLS_VERIFY_CLIENT'] = 'never'
          else
            @environment['LDAP_TLS'] = 'false'
          end
        end

        def tls?
          @environment['LDAP_TLS'] != 'false'
        end

        def username
          LDAP_USER
        end

        def password
          LDAP_PASSWORD
        end

        def add_network_alias(name)
          @network_aliases.push(name)
        end

        def name
          @name ||= "openldap-#{SecureRandom.hex(4)}"
        end

        def hostname
          "#{name}.#{network}"
        end

        def instance
          raise 'Please provide a block!' unless block_given?

          prepare
          start

          yield self
        ensure
          teardown
        end

        def prepare
          @docker.pull(LDAP_IMAGE, LDAP_IMAGE_TAG)

          return if @docker.network_exists?(network)

          @docker.network_create(network)
        end

        def start
          # copy-service needed for bootstraping LDAP user:
          # https://github.com/osixia/docker-openldap#seed-ldap-database-with-ldif
          docker.run(LDAP_IMAGE, LDAP_IMAGE_TAG, '--copy-service') do |command|
            command << '-d '
            command << "--name #{name}"
            command << "--net #{network}"
            command << "--hostname #{hostname}"

            @volumes.to_h.each do |to, from|
              command.volume(to, from, 'Z')
            end

            @environment.to_h.each do |key, value|
              command.env(key, value)
            end

            @network_aliases.to_a.each do |network_alias|
              command << "--network-alias #{network_alias}"
            end
          end
        end

        def restart
          @docker.restart(name)
        end

        def teardown
          raise 'Invalid instance name!' unless name

          @docker.stop(name)
          @docker.remove(name)
        end

        def pull
          @docker.pull(LDAP_IMAGE, LDAP_IMAGE_TAG)
        end

        def to_config
          config = YAML.safe_load <<~CFG
            main:
              label: LDAP
              host: #{hostname}
              port: #{tls? ? LDAP_TLS_PORT : LDAP_PORT}
              uid: 'uid'
              bind_dn: #{BIND_DN}
              password: #{ADMIN_PASSWORD}
              method: #{tls? ? 'simple_tls' : 'plain'}
              verify_certificates: false
              base: #{BASE_DN}
              user_filter: ''
              group_base: #{GROUP_BASE}
              admin_group: #{ADMIN_GROUP}
              external_groups: ''
              sync_ssh_keys: false
          CFG

          # Quotes get eaten up when the string is set in the environment
          config.to_s.gsub("\"", "\\\"")
        end

        def set_gitlab_credentials
          ::Gitlab::QA::Runtime::Env.ldap_username = username
          ::Gitlab::QA::Runtime::Env.ldap_password = password
        end

        def set_accept_insecure_certs
          ::Gitlab::QA::Runtime::Env.accept_insecure_certs = 'true'
        end
      end
    end
  end
end
