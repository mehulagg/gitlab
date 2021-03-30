import dateFormat from 'dateformat';
import { dateFormats } from 'ee/analytics/shared/constants';
import { transformStagesForPathNavigation, filterStagesByHiddenStatus } from '../utils';

export const pathNavigationData = ({ stages, medians, stageCounts, selectedStage }) => {
  return transformStagesForPathNavigation({
    stages: filterStagesByHiddenStatus(stages, false),
    medians,
    stageCounts,
    selectedStage,
  });
};

export const requestParams = (state) => {
  const {
    selectedStage: { id: stageId },
    currentGroup: { path: groupId },
    selectedValueStream: { id: valueStreamId },
  } = state;
  return { valueStreamId, groupId, stageId };
};

export const filterParams = (state) => {
  const { id, createdAfter = null, createdBefore = null } = state;
  return {
    project_ids: [id],
    created_after: createdAfter ? dateFormat(createdAfter, dateFormats.isoDate) : null,
    created_before: createdBefore ? dateFormat(createdBefore, dateFormats.isoDate) : null,
  };
};
