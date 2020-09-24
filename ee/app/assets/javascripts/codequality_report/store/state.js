export default () => ({
  endpoint: '',
  allCodequalityIssues: [],
  isLoadingCodequality: false,
  loadingCodequalityFailed: false,
  codeQualityError: null,
  pageInfo: {
    page: 1,
    perPage: 25,
    total: 0,
  },
});
