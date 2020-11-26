import initEpicCreateApp from 'ee/epic/epic_bundle';
import FilteredSearchTokenKeysEpics from 'ee/filtered_search/filtered_search_token_keys_epics';
import initRoadmap from 'ee/roadmap/roadmap_bundle';
import initFilteredSearch from '~/pages/search/init_filtered_search';

initFilteredSearch({
  page: 'epics',
  isGroup: true,
  isGroupDecendent: true,
  useDefaultState: false,
  filteredSearchTokenKeys: FilteredSearchTokenKeysEpics,
  stateFiltersSelector: '.epics-state-filters',
});
initEpicCreateApp(true);
initRoadmap();
