export default () => ({
  inputValue: '',
  isLoadingProjects: false,
  projectEndpoints: {
    list: null,
    add: null,
  },
  searchQuery: '',
  pageInfo: {
    totalPages: 0,
    totalResults: 0,
    nextPage: 0,
    currentPage: 0,
  },
  projects: [],
  projectSearchResults: [],
  projectsPage: {
    pageInfo: {
      totalPages: 1,
      totalResults: 0,
      nextPage: 0,
      prevPage: 0,
      currentPage: 1,
    },
  },
  selectedProjects: [],
  messages: {
    noResults: false,
    searchError: false,
    minimumQuery: false,
  },
  searchCount: 0,
});
