export default ({ dropdownType = '', withDeprecatedStyle = false } = {}) => ({
  namespace: '',
  dropdownType,
  storageKey: '',
  searchQuery: '',
  isLoadingItems: false,
  isFetchFailed: false,
  items: [],
  withDeprecatedStyle,
});
