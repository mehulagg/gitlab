const createState = ({ query }) => ({
  query,
  initialGroup: null,
  fetchingInitialGroup: false,
  groups: [],
  fetchingGroups: false,
});
export default createState;
