const createState = ({ primaryVersion, primaryRevision, replicableTypes }) => ({
  primaryVersion,
  primaryRevision,
  replicableTypes,
  nodes: [],
  isLoading: false,
  nodeToBeRemoved: null,
});
export default createState;
