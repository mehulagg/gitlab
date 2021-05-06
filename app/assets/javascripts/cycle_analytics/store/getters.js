import { transformStagesForPathNavigation } from '../utils';

export const filterStagesByHiddenStatus = (stages = [], isHidden = true) =>
  stages.filter(({ hidden = false }) => hidden === isHidden);

export const pathNavigationData = ({ stages, medians, stageCounts, selectedStage }) => {
  console.log('medians', medians);
  return transformStagesForPathNavigation({
    stages: filterStagesByHiddenStatus(stages, false),
    medians,
    stageCounts,
    selectedStage,
  });
};
