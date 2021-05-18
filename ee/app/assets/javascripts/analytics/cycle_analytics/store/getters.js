import dateFormat from 'dateformat';
import { isNumber } from 'lodash';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import httpStatus from '~/lib/utils/http_status';
import { filterToQueryObject } from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';
import { dateFormats } from '../../shared/constants';
import {
  DEFAULT_VALUE_STREAM_ID,
  OVERVIEW_STAGE_CONFIG,
  PAGINATION_TYPE,
  OVERVIEW_STAGE_ID,
} from '../constants';
import { transformStagesForPathNavigation } from '../utils';

export const hasNoAccessError = (state) => state.errorCode === httpStatus.FORBIDDEN;

export const currentValueStreamId = ({ selectedValueStream }) =>
  selectedValueStream?.id || DEFAULT_VALUE_STREAM_ID;

export const currentGroupPath = ({ currentGroup }) => currentGroup?.fullPath || null;

export const selectedProjectIds = ({ selectedProjects }) =>
  selectedProjects?.map(({ id }) => getIdFromGraphQLId(id)) || [];

export const cycleAnalyticsRequestParams = (state, getters) => {
  const {
    startDate = null,
    endDate = null,
    filters: {
      authors: { selected: selectedAuthor },
      milestones: { selected: selectedMilestone },
      assignees: { selectedList: selectedAssigneeList },
      labels: { selectedList: selectedLabelList },
    },
  } = state;

  const filterBarQuery = filterToQueryObject({
    milestone_title: selectedMilestone,
    author_username: selectedAuthor,
    label_name: selectedLabelList,
    assignee_username: selectedAssigneeList,
  });

  return {
    project_ids: getters.selectedProjectIds,
    created_after: startDate ? dateFormat(startDate, dateFormats.isoDate) : null,
    created_before: endDate ? dateFormat(endDate, dateFormats.isoDate) : null,
    ...filterBarQuery,
  };
};

export const paginationParams = ({ pagination: { page, sort, direction } }) => ({
  pagination: PAGINATION_TYPE,
  sort,
  direction,
  page,
});

const filterStagesByHiddenStatus = (stages = [], isHidden = true) =>
  stages.filter(({ hidden = false }) => hidden === isHidden);

export const hiddenStages = ({ stages }) => filterStagesByHiddenStatus(stages);
export const activeStages = ({ stages }) => filterStagesByHiddenStatus(stages, false);

export const enableCustomOrdering = ({ stages, errorSavingStageOrder }) =>
  stages.some((stage) => isNumber(stage.id)) && !errorSavingStageOrder;

export const customStageFormActive = ({ isCreatingCustomStage, isEditingCustomStage }) =>
  Boolean(isCreatingCustomStage || isEditingCustomStage);

export const isOverviewStageSelected = ({ selectedStage }) =>
  selectedStage?.id === OVERVIEW_STAGE_ID;

/**
 * Until there are controls in place to edit stages outside of the stage table,
 * the path navigation component will only display active stages.
 *
 * https://gitlab.com/gitlab-org/gitlab/-/issues/216227
 */
export const pathNavigationData = ({ stages, medians, stageCounts, selectedStage }) =>
  transformStagesForPathNavigation({
    stages: [OVERVIEW_STAGE_CONFIG, ...filterStagesByHiddenStatus(stages, false)],
    medians,
    stageCounts,
    selectedStage,
  });

export const selectedStageCount = ({ selectedStage, stageCounts }) =>
  stageCounts[selectedStage.id] || null;
