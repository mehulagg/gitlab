import service from '../../services';
import { GITLAB_CI_STAGES } from '../mutation_types';

export const maybeFetchGitlabCiYaml = ({ dispatch, state }) => {
  const ciFileContent = state.entries['.gitlab-ci.yml']?.content;

  if (ciFileContent) {
    dispatch('fetchGitlabCiYaml', ciFileContent);
  }
};

export const fetchGitlabCiYaml = ({ commit, state }, content) =>
  service.getCiConfig(state.currentProjectId, content).then((data) => {
    commit(GITLAB_CI_STAGES, data?.stages);
  });

export const fetchCallouts = ({ commit }) =>
  service.fetchUserCallouts().then((user) => {
    commit('SET_USER_CALLOUTS', user?.callouts);
  });

export const dismissCallout = ({ commit }, callout) =>
  service.dismissUserCallout(callout).then((data) => {
    commit('SET_USER_CALLOUT', data?.callout);
  });
