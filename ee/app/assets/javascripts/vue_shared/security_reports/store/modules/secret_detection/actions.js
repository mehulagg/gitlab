import * as types from './mutation_types';

export * from '~/vue_shared/security_reports/store/modules/secret_detection/actions';

export const updateVulnerability = ({ commit }, vulnerability) =>
  commit(types.UPDATE_VULNERABILITY, vulnerability);
