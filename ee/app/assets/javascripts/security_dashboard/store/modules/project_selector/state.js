export default () => ({
  inputValue: '',
  isLoadingProjects: false,
  isAddingProjects: false,
  isRemovingProject: false,
  projectEndpoints: {
    list: null,
    add: null,
  },
  searchQuery: '',
  projects: [],
  projectSearchResults: [],
  selectedProjects: [],
  messages: {
    noResults: false,
    searchError: false,
    minimumQuery: false,
  },
  searchCount: 0,
  pageInfo: {
    page: 0,
    nextPage: 0,
    total: 0,
    totalPages: 0,
  },
});
