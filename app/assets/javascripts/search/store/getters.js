export const loadingGroups = (state) => {
  return state.fetchingGroups || state.fetchingFrequentGroups;
};

export const loadingProjects = (state) => {
  return state.fetchingProjects || state.fetchingFrequentProjects;
};
