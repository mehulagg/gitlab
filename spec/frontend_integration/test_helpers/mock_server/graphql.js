import { buildSchema, graphql } from 'graphql';
import { memoize } from 'lodash';
import { requireGitLabSchema } from 'helpers/require_gitlab_schema_graphql';

const graphqlResolvers = {
  project({ fullPath }, schema) {
    const result = schema.projects.findBy({ path_with_namespace: fullPath });
    const userPermission = schema.db.userPermissions[0];

    return {
      ...result.attrs,
      userPermissions: {
        ...userPermission,
      },
    };
  },
};
const buildGraphqlSchema = memoize(() => buildSchema(requireGitLabSchema().loc.source.body));

export const graphqlQuery = (query, variables, schema) =>
  graphql(buildGraphqlSchema(), query, graphqlResolvers, schema, variables);
