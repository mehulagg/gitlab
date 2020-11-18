import FilteredSearchTokenKeysEpics from 'ee/filtered_search/filtered_search_token_keys_epics';
import initEpicCreateApp from 'ee/epic/epic_bundle';
import initRoadmap from 'ee/roadmap/roadmap_bundle';
import initFilteredSearch from '~/pages/search/init_filtered_search';
import UserCallout from '~/user_callout';

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

// eslint-disable-next-line no-new
new UserCallout({ className: 'js-epics-limit-callout' });
