module Mutations
  module Releases
    class Create < BaseMutation
      graphql_name 'ReleaseCreate'

      field :release,
            Types::ReleaseType,
            null: true,
            description: 'The release after mutation'

      argument :something, GraphQL::STRING_TYPE,
               required: true,
               description: 'Something!'

      def resolve(args)
        pp 'Release created!'
        pp args

        {
          release: {
            tag: "hello"
          },
          errors: []
        }
      end
    end
  end
end
