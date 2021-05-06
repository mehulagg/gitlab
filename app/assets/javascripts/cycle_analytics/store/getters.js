// TODO: move this util locally
import { transformStagesForPathNavigation } from 'ee/analytics/cycle_analytics/utils';

// TODO: add tests
export const filterStagesByHiddenStatus = (stages = [], isHidden = true) =>
  stages.filter(({ hidden = false }) => hidden === isHidden);

// TODO: move tests locally - leave overview tests in ee
export const pathNavigationData = ({ stages, medians, selectedStage }) =>
  transformStagesForPathNavigation({
    stages: filterStagesByHiddenStatus(stages, false),
    medians,
    selectedStage,
  });
