import * as getters from '~/cycle_analytics/store/getters';
import {
  allowedStages,
  stageMedians,
  transformedProjectStagePathData,
  selectedStage,
} from '../mock_data';

// TODO: move path navigation component to CE ee/spec/frontend/analytics/cycle_analytics/components/path_navigation_spec.js
describe('Value stream analytics getters', () => {
  describe('pathNavigationData', () => {
    it('returns the transformed data', () => {
      const state = { stages: allowedStages, medians: stageMedians, selectedStage };
      expect(getters.pathNavigationData(state)).toEqual(transformedProjectStagePathData);
    });
  });

  describe('filterStagesByHiddenStatus', () => {
    const hiddenStages = [{ title: 'three', hidden: true }];
    const visibleStages = [
      { title: 'one', hidden: false },
      { title: 'two', hidden: false },
    ];
    const mockStages = [...visibleStages, ...hiddenStages];

    it.each`
      isHidden     | result
      ${false}     | ${visibleStages}
      ${undefined} | ${hiddenStages}
      ${true}      | ${hiddenStages}
    `('with isHidden=$isHidden returns matching stages', ({ isHidden, result }) => {
      expect(getters.filterStagesByHiddenStatus(mockStages, isHidden)).toEqual(result);
    });
  });
});
