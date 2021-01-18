import { convertToGraphQLId, getIdFromGraphQLId } from '~/graphql_shared/utils';
import { s__ } from '~/locale';

import getComplianceFrameworkQuery from '../graphql/queries/get_compliance_framework.query.graphql';
import createComplianceFrameworkMutation from '../graphql/queries/create_compliance_framework.mutation.graphql';
import updateComplianceFrameworkMutation from '../graphql/queries/update_compliance_framework.mutation.graphql';

export default class ComplianceFrameworksService {
  #graphQlIdType = 'ComplianceManagement::Framework';

  constructor(client, groupPath, id = null) {
    this.client = client;
    this.groupPath = groupPath;
    this.id = id;
  }

  #i18n = {
    unknownFrameworkError: s__(
      'ComplianceFrameworks|Unknown compliance framework given. Please try a different framework or refresh the page',
    ),
    saveError: s__(
      'ComplianceFrameworks|Unable to save this compliance framework. Please try again',
    ),
  };

  async getComplianceFramework() {
    if (!this.id) {
      return {};
    }

    const { data } = await this.client.query({
      query: getComplianceFrameworkQuery,
      variables: {
        fullPath: this.groupPath,
        complianceFramework: convertToGraphQLId(this.#graphQlIdType, this.id),
      },
    });

    const nodes = data.namespace?.complianceFrameworks?.nodes || [];

    if (!nodes.length) {
      throw new Error(this.#i18n.unknownFrameworkError);
    }

    return {
      ...nodes[0],
      parsedId: getIdFromGraphQLId(nodes[0].id),
    };
  }

  async putComplianceFramework(framework) {
    const mutation = this.id
      ? updateComplianceFrameworkMutation
      : createComplianceFrameworkMutation;
    const variables = this.id
      ? ComplianceFrameworksService.updateMutationVariables(framework)
      : this.createMutationVariables(framework);

    let response = {};

    try {
      response = await this.client.mutate({
        mutation,
        variables,
      });
    } catch (e) {
      throw new Error(this.#i18n.saveError);
    }

    const errors = this.id
      ? response.data?.updateComplianceFramework?.errors
      : response.data?.createComplianceFramework?.errors || [];

    if (errors.length) {
      throw new Error(errors[0]);
    }

    return this.id
      ? {}
      : {
          ...response.data?.createComplianceFramework?.framework,
          parsedId: getIdFromGraphQLId(response.data?.createComplianceFramework?.framework.id),
        };
  }

  createMutationVariables(framework) {
    return {
      input: {
        namespacePath: this.groupPath,
        params: {
          name: framework.name,
          description: framework.description,
          color: framework.color,
        },
      },
    };
  }

  static updateMutationVariables(framework) {
    return {
      input: {
        id: framework.id,
        params: {
          name: framework.name,
          description: framework.description,
          color: framework.color,
        },
      },
    };
  }
}
