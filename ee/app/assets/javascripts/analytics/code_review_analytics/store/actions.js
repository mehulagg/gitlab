export function setFilters({ dispatch }) {
  return Promise.all([
    dispatch('mergeRequests/setPage', 1),
    dispatch('mergeRequests/fetchMergeRequests', null),
  ]);
}
