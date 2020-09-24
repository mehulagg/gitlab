import * as getters from 'ee/analytics/cycle_analytics/store/modules/custom_stages/getters';

describe('Custom stages getters', () => {
  describe.each`
    state                                                            | result
    ${{ isCreatingCustomStage: true, isEditingCustomStage: true }}   | ${true}
    ${{ isCreatingCustomStage: false, isEditingCustomStage: true }}  | ${true}
    ${{ isCreatingCustomStage: true, isEditingCustomStage: false }}  | ${true}
    ${{ isCreatingCustomStage: false, isEditingCustomStage: false }} | ${false}
  `('customStageFormActive', ({ state, result }) => {
    it(`with state ${state} returns ${result}`, () => {
      expect(getters.customStageFormActive(state)).toEqual(result);
    });
  });
});
