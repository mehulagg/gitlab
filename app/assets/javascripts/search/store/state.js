import { GROUPS_LOCAL_STORAGE_KEY, PROJECTS_LOCAL_STORAGE_KEY } from './constants';

const createState = ({ query }) => ({
  query,
  groups: [],
  fetchingGroups: false,
  fetchingFrequentGroups: false,
  projects: [],
  fetchingProjects: false,
  fetchingFrequentProjects: false,
  frequentItems: {
    [GROUPS_LOCAL_STORAGE_KEY]: [],
    [PROJECTS_LOCAL_STORAGE_KEY]: [],
  },
});
export default createState;
