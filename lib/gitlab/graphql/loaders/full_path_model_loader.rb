# frozen_string_literal: true

module Gitlab
  module Graphql
    module Loaders
      # Suitable for use to find resources that expose `where_full_path_in`,
      # such as Project, Group, Namespace
      class FullPathModelLoader
        attr_reader :model_class, :full_path

        def initialize(model_class, full_path)
          @model_class = model_class
          @full_path = full_path
        end

        def find
          object = model_class.find_by_full_path(full_path)
          if object
            # TODO: hack that changes global state
            NamespaceShard.set_current_shard(object.database_shard_name)
          end
          object
          # BatchLoader::GraphQL.for(full_path).batch(key: model_class) do |full_paths, loader, args|
          #   # `with_route` avoids an N+1 calculating full_path
          #   args[:key].where_full_path_in(full_paths).with_route.each do |model_instance|
          #     loader.call(model_instance.full_path, model_instance)
          #   end
          # end
        end
      end
    end
  end
end
