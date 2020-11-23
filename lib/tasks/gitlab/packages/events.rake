require 'logger'

desc "GitLab | Packages | Events | Generate hll counter events file for packages"
namespace :gitlab do
  namespace :packages do
    namespace :events do
      task generate: :environment do
        logger = Logger.new(STDOUT)
        logger.info('Building list of package events...')

        path = File.join(File.dirname(::Gitlab::UsageDataCounters::HLLRedisCounter::KNOWN_EVENTS_PATH), 'package_events.yml')
        File.open(path, "w") { |file| file << generate_unique_events_list.to_yaml }

        path = ::Gitlab::UsageDataCounters::GuestPackageEventCounter::KNOWN_EVENTS_PATH
        File.open(path, "w") { |file| file << guest_events_list.to_yaml }

        logger.info("Events file `#{path}` generated successfully")
      rescue => e
        logger.error("Error building events list: #{e}")
      end

      def event_pairs
        ::Packages::Event.event_types.keys.product(::Packages::Event::EVENT_SCOPES.keys)
      end

      def generate_unique_events_list
        event_pairs.each_with_object([]) do |(event_type, event_scope), events|
          ::Packages::Event.originator_types.keys.excluding('guest').each do |originator|
            if name = ::Packages::Event.allowed_event_name(event_scope, event_type, originator)
              events << {
                "name" => name,
                "category" => "#{event_scope}_packages",
                "aggregation" => "weekly",
                "redis_slot" => "package"
              }
            end
          end
        end.sort { |a, b| a["name"] <=> b["name"] }
      end

      def guest_events_list
        event_pairs.map do |event_type, event_scope|
          ::Packages::Event.allowed_event_name(event_scope, event_type, "guest")
        end.compact.sort
      end
    end
  end
end
