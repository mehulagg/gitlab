# frozen_string_literal: true

namespace :gitlab do
  namespace :geo do
    desc "Gitlab | Geo | Check replication/verification status"
    task check_replication_verification_status: :environment do
      abort GEO_LICENSE_ERROR_TEXT unless Gitlab::Geo.license_allows?
      abort GEO_LICENSE_ERROR_TEXT unless Gitlab::Geo.license_allows?

      current_node_status = GeoNodeStatus.current_node_status
      geo_node = current_node_status.geo_node

      unless geo_node.secondary?
        puts 'This command is only available on a secondary node'.color(:red)
        exit
      end

      puts

      status_check = Gitlab::Geo::GeoNodeStatusCheck.new(current_node_status, geo_node)

      status_check.print_replication_verification_status
      complete = status_check.replication_verification_complete?

      if complete
        puts 'SUCCESS - Replication is up-to-date.'.color(:green)
        exit 0
      else
        puts "ERROR - Replication is not up-to-date. \n"\
        "Please see documentation to complete replication: "\
        "https://docs.gitlab.com/ee/administration/geo/disaster_recovery"\
        "/planned_failover.html#ensure-geo-replication-is-up-to-date"
               .color(:red)
        exit 1
      end
    end

    desc 'GitLab | Geo | Check Geo database replication'
    task check_database_replication_working: :gitlab_environment do
      unless ::Gitlab::Geo.secondary?
        abort 'This command is only available on a secondary node'.color(:red)
      end

      geo_health_check = Gitlab::Geo::HealthCheck.new

      enabled = geo_health_check.replication_enabled?
      success = enabled && geo_health_check.replication_working?

      if success
        puts 'SUCCESS - Database replication is working.'.color(:green)
      elsif enabled
        abort "ERROR - Database replication is enabled, but not working.\n"\
              "This rake task is intended for programmatic use. Please run\n"\
              "the full Geo check task for more information:\n"\
              "  gitlab-rake gitlab:geo:check".color(:red)
      else
        abort "ERROR - Database replication is not enabled.\n"\
              "This rake task is intended for programmatic use. Please run\n"\
              "the full Geo check task for more information:\n"\
              "  gitlab-rake gitlab:geo:check".color(:red)
      end
    end
  end
end
