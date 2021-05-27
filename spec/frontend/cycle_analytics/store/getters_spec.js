import * as getters from '~/cycle_analytics/store/getters';
import {
  allowedStages,
  stageMedians,
  transformedProjectStagePathData,
  selectedStage,
} from '../mock_data';

console.log('allowedStages', allowedStages);
console.log('stageMedians', stageMedians);
console.log('transformedProjectStagePathData', transformedProjectStagePathData);
console.log('selectedStage', selectedStage);

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
