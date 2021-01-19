import createStateCE from '~/boards/stores/state';

export default () => ({
  ...createStateCE(),

  canAdminEpic: false,
  isShowingEpicsSwimlanes: false,
  epicsSwimlanesFetchInProgress: false,
  /*
    Both 'epicsCache' and 'epics' store fetched epics
    'epicsCache' strictly add the fetched epics,
    'epics' may get reset over time as filters change.

    For efficiency, we may consider only storing identifiers in 'epics':
    https://gitlab.com/gitlab-org/gitlab/-/issues/255995.
  */
  epics: [],
  epicsCache: {},
  epicFetchInProgress: false,
  epicsFlags: {},
});
