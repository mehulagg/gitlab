import { uniq } from 'lodash';

export const joinedBranches = (state) => {
  return uniq(state.branches).sort();
};

export const joinedProjects = (state) => {
  return uniq(state.projects).sort();
};