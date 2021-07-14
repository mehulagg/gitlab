export default ({ namespaceId = null, namespaceName = null, tableSortableFields, filteredSearchBar } = {}) => ({
  isLoading: false,
  hasError: false,
  namespaceId,
  namespaceName,
  members: [],
  total: null,
  page: null,
  perPage: null,
  billableMemberToRemove: null,
  userDetails: {},
  tableSortableFields,
  filteredSearchBar,
});
