# frozen_string_literal: true

module SystemCheck
  module Geo
    class CurrentNodeCheck < SystemCheck::BaseCheck
      set_name "This machine's Geo node name matches a database record"

      # Overriding so we can output current node name and what record it matches, in case either is unexpected
      def self.check_pass
        node_type = Gitlab::Geo.primary? ? 'primary' : 'secondary'

        "yes, found a #{node_type} node named \"#{GeoNode.current_node_name}\""
      end

      def check?
        GeoNode.current_node.present?
      end

      def show_error
        configured_name = GeoNode.current_node_name
        db_names = GeoNode.all.map(&:name)

        try_fixing_it(
          "You could add or update a Geo node database record, setting the name to match this machine's Geo node name \"#{configured_name}\".",
          "Or you could set this machine's Geo node name to match the name of an existing database record: \"#{db_names.join('", "')}\""
        )

        for_more_information('doc/administration/geo/replication/troubleshooting.md#can-geo-detect-the-current-node-correctly')
      end
    end
  end
end
