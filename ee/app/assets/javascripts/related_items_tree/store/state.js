export default () => ({
  // Initial Data
  parentItem: {},
  epicsEndpoint: '',
  issuesEndpoint: '',

  children: {},
  childrenFlags: {},
  epicsCount: 0,
  issuesCount: 0,

  // Add Item Form Data
  actionType: '',
  itemInputValue: '',
  pendingReferences: [],
  itemAutoCompleteSources: {},

  // UI Flags
  itemsFetchInProgress: false,
  itemsFetchFailure: false,
  itemsFetchResultEmpty: false,
  itemAddInProgress: false,
  itemCreateInProgress: false,
  showAddItemForm: false,
  showCreateEpicForm: false,
  autoCompleteEpics: false,
  autoCompleteIssues: false,
  removeItemModalProps: {
    parentItem: {},
    item: {},
  },
});
