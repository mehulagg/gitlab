# frozen_string_literal: true

module Gitlab
  module Ci
    class Trace
      ##
      # Class that describes CI/CD build logs metadata (chunks, pending
      # states, checksums) and their datastore.
      #
      class Metadata
        def self.using_primary_source(&block)
          self.new.use_primary(&block)
        end

        ##
        # This method is overriden in EE to make sure we can disable database
        # load balancing when reading trace metadata. Here, it simply yields.
        #
        def use_primary(&block)
          yield
        end
      end
    end
  end
end

::Gitlab::Ci::Trace::Metadata.prepend_if_ee('EE::Gitlab::Ci::Trace::Metadata')
