/* global gapi */
import * as types from './mutation_types';

const gapiResourceListRequest = ({ resource, params, commit, mutation, payloadKey }) =>
  new Promise((resolve, reject) => {
    const request = resource.list(params);

    return request.then(
      resp => {
        const { result } = resp;

        commit(mutation, result[payloadKey]);

        resolve();
      },
      resp => {
        reject(resp);
      },
    );
  });

export default {
  setProject: ({ commit }, selectedProject) => {
    commit(types.SET_PROJECT, selectedProject);
  },

  setZone: ({ commit }, selectedZone) => {
    commit(types.SET_ZONE, selectedZone);
  },

  setMachineType: ({ commit }, selectedMachineType) => {
    commit(types.SET_MACHINE_TYPE, selectedMachineType);
  },

  setIsValidatingProjectBilling: ({ commit }, isValidatingProjectBilling) => {
    commit(types.SET_IS_VALIDATING_PROJECT_BILLING, isValidatingProjectBilling);
  },

  fetchProjects: ({ commit }) =>
    gapiResourceListRequest({
      resource: gapi.client.cloudresourcemanager.projects,
      params: {},
      commit,
      mutation: types.SET_PROJECTS,
      payloadKey: 'projects',
    }),

  validateProjectBilling: ({ dispatch, commit, state }) =>
    new Promise((resolve, reject) => {
      const request = gapi.client.cloudbilling.projects.getBillingInfo({
        name: `projects/${state.selectedProject.projectId}`,
      });

      commit(types.SET_ZONE, '');
      commit(types.SET_MACHINE_TYPE, '');

      return request.then(
        resp => {
          const { billingEnabled } = resp.result;

          commit(types.SET_PROJECT_BILLING_STATUS, !!billingEnabled);
          dispatch('setIsValidatingProjectBilling', false);
          resolve();
        },
        resp => {
          dispatch('setIsValidatingProjectBilling', false);
          reject(resp);
        },
      );
    }),

  fetchZones: ({ commit, state }) =>
    gapiResourceListRequest({
      resource: gapi.client.compute.zones,
      params: {
        project: state.selectedProject.projectId,
      },
      commit,
      mutation: types.SET_ZONES,
      payloadKey: 'items',
    }),

  fetchMachineTypes: ({ commit, state }) =>
    gapiResourceListRequest({
      resource: gapi.client.compute.machineTypes,
      params: {
        project: state.selectedProject.projectId,
        zone: state.selectedZone,
      },
      commit,
      mutation: types.SET_MACHINE_TYPES,
      payloadKey: 'items',
    }),
};
