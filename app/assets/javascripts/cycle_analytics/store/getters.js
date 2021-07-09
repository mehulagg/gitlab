import { transformStagesForPathNavigation, filterStagesByHiddenStatus } from '../utils';

export const pathNavigationData = ({ stages, medians, stageCounts, selectedStage }) => {
  return transformStagesForPathNavigation({
    stages: filterStagesByHiddenStatus(stages, false),
    medians,
    stageCounts,
    selectedStage,
  });
};

export const vsaRequestParams = (state) => {
  console.log('vsaRequestParams::state', state);
  const {
    selectedStage: { id: stageId = null },
    // parentId: groupId,
    parentPath: groupId,
    selectedValueStream: { id: valueStreamId },
  } = state;
  return { valueStreamId, groupId, stageId };
};
