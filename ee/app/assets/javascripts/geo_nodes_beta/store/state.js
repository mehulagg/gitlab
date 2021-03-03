const createState = ({ primaryVersion, primaryRevision, replicableTypes }) => ({
  primaryVersion,
  primaryRevision,
  replicableTypes,
  nodes: [],
  isLoading: false,
});
export default createState;
