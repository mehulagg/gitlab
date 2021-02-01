import { isNil } from 'lodash';
import { convertToCamelCase } from '~/lib/utils/text_utility';
import { GIT, FILE } from '../constants';

export const gitDataTypes = (state) =>
  state.replicableTypes.filter((replicable) => replicable.dataType === GIT);

export const fileDataTypes = (state) =>
  state.replicableTypes.filter((replicable) => replicable.dataType === FILE);

export const verificationInfo = (state) => (id) => {
  const node = state.nodes.find((n) => n.id === id);
  const variables = {};

  if (node.primary) {
    variables.success = 'ChecksummedCount';
    variables.failed = 'ChecksumFailedCount';
  } else {
    variables.success = 'VerifiedCount';
    variables.failed = 'VerificationFailedCount';
  }

  return state.replicableTypes
    .map((replicable) => {
      const camelCaseName = convertToCamelCase(replicable.namePlural);

      return {
        dataType: replicable.dataType,
        title: replicable.titlePlural,
        values: {
          total: node[`${camelCaseName}Count`],
          success: node[`${camelCaseName}${variables.success}`],
          failed: node[`${camelCaseName}${variables.failed}`],
        },
      };
    })
    .filter((replicable) =>
      Boolean(!isNil(replicable.values.success) || !isNil(replicable.values.failed)),
    );
};

export const syncInfo = (state) => (id) => {
  const node = state.nodes.find((n) => n.id === id);

  return state.replicableTypes.map((replicable) => {
    const camelCaseName = convertToCamelCase(replicable.namePlural);

    return {
      enabled: node[`${camelCaseName}replicationEnabled`],
      dataType: replicable.dataType,
      title: replicable.titlePlural,
      values: {
        total: node[`${camelCaseName}Count`],
        success: node[`${camelCaseName}SyncedCount`],
        failed: node[`${camelCaseName}FailedCount`],
      },
    };
  });
};
