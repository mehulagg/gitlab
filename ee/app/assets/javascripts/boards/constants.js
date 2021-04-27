import { issuableTypes } from '~/boards/constants';
import updateBoardListMutation from '~/boards/graphql/board_list_update.mutation.graphql';

import { s__ } from '~/locale';

import updateEpicBoardListMutation from './graphql/epic_board_list_update.mutation.graphql';

export const DRAGGABLE_TAG = 'div';

export const EPIC_LANE_BASE_HEIGHT = 40;

/* eslint-disable @gitlab/require-i18n-strings */
export const EpicFilterType = {
  any: 'Any',
  none: 'None',
};

export const SupportedFiltersEE = ['epicId', 'iterationTitle', 'weight'];

export const IterationFilterType = {
  any: 'Any',
  none: 'None',
  current: 'Current',
};

export const IterationIDs = {
  NONE: 0,
  CURRENT: -4,
};

export const MilestoneFilterType = {
  any: 'Any',
  none: 'None',
};

export const MilestoneIDs = {
  NONE: 0,
};

export const WeightFilterType = {
  none: 'None',
};

export const WeightIDs = {
  NONE: -2,
  ANY: -1,
};

export const GroupByParamType = {
  epic: 'epic',
};

export const ErrorMessages = {
  fetchIssueError: s__(
    'Boards|An error occurred while fetching the board issues. Please reload the page.',
  ),
  fetchEpicsError: s__(
    'Boards|An error occurred while fetching the board epics. Please reload the page.',
  ),
};

export const updateListQueries = {
  [issuableTypes.issue]: {
    mutation: updateBoardListMutation,
  },
  [issuableTypes.epic]: {
    mutation: updateEpicBoardListMutation,
  },
};

export default {
  DRAGGABLE_TAG,
  EpicFilterType,
};
