export default () => ({
  // Initial Data
  groupId: null,
  issueId: null,
  selectedEpic: {},
  selectedEpicIssueId: null,

  // Store
  searchQuery: '',
  epics: [],

  // UI Flags
  variant: '',
  epicSelectInProgress: false,
  epicsFetchInProgress: false,
});
