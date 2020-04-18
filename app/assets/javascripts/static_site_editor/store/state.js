const createState = (initialState = {}) => ({
  username: null,
  projectId: null,
  sourcePath: null,

  isLoadingContent: false,
  isSavingChanges: false,

  originalContent: '',
  content: '',
  title: '',

  savedContentMeta: null,

  ...initialState,
});

export default createState;
