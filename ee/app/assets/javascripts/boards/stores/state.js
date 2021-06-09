import createStateCE from '~/boards/stores/state';

export default () => ({
  ...createStateCE(),

  canAdminEpic: false,
  isShowingEpicsSwimlanes: false,
  epicsSwimlanesFetchInProgress: {
    epicLanesFetchInProgress: false,
    listItemsFetchInProgress: false,
  },
  epics: [],
  milestones: [],
  milestonesLoading: false,
  iterations: [],
  iterationsLoading: false,
  assignees: [],
  assigneesLoading: false,
});
