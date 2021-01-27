# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          HANDLERS = {
            'source' => {
              'location' => Tracking::Source::Location,
              'scope+offset' => Tracking::Source::ScopeOffset
            },
            'hashed' => {
              'hashed' => Tracking::Hashed
            }
          }.freeze

          def self.create_trackings(track_data)
            return [] if track_data.nil?

            track_type = track_data['type']
            return [] unless HANDLERS.has_key?(track_type)

            track_methods = {}
            num_pos = track_data['positions'].size
            track_data['positions'].each do |pos|
              add_location_method(pos) if track_type == 'source'

              pos['fingerprints'].each do |key, val|
                info = track_methods[key] ||= {
                  count: 0,
                  total_fingerprint: ''
                }
                info[:count] += 1
                info[:total_fingerprint] += ',' unless info[:total_fingerprint].empty?
                info[:total_fingerprint] += val
              end
            end

            handlers = HANDLERS[track_type]
            res = track_methods.map do |key, info|
              if info[:count] != num_pos
                nil
              elsif !handlers.has_key?(key)
                # skip it
                nil
              else
                handlers[key].new(info[:total_fingerprint], track_data)
              end
            end

            res.compact
          end

          def self.add_location_method(position)
            return if position['fingerprints'].has_key?('location')

            position['fingerprints']['location'] = [
              position['file'],
              position['line_start'],
              position['line_end']
            ].join(':')
          end
        end
      end
    end
  end
end
