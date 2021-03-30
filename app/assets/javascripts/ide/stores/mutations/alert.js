import { GITLAB_CI_STAGES, SET_USER_CALLOUTS, SET_USER_CALLOUT } from '../mutation_types';

export default {
  [GITLAB_CI_STAGES](state, stages = {}) {
    state.gitlabCiStages = stages;
  },
  [SET_USER_CALLOUTS](state, callouts = { edges: [] }) {
    state.callouts = callouts;
  },
  [SET_USER_CALLOUT](state, callout = { name: '' }) {
    state.callouts.edges = [
      ...state.callouts.edges.filter(({ name }) => name !== callout.name),
      callout,
    ];
  },
};
