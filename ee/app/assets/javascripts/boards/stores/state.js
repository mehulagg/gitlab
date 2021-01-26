import createStateCE from '~/boards/stores/state';

export default () => ({
  ...createStateCE(),

  canAdminEpic: false,
  isShowingEpicsSwimlanes: false,
  epicsSwimlanesFetchInProgress: false,
  // The epic data stored in 'epics' do not always persist
  // and will be cleared with changes to the filter.
  epics: [],
  epicsCacheById: {},
  epicFetchInProgress: false,
  epicsFlags: {},
});
