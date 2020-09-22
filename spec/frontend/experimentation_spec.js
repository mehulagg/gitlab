import * as experimentUtils from '~/experimentation';

describe('experiment Utilities', () => {
  describe('featureFlagName', () => {
    it('appends the intended suffix to experiment key to make up the feature flag name', () => {
      expect(experimentUtils.featureFlagName('abc')).toEqual('abcExperimentPercentage');
    });
  });

  describe('experimentEnabled', () => {
    it.each`
      experimentKey | value
      ${'abc'}      | ${true}
      ${'abc'}      | ${false}
    `(
      'returns correct value of $value for $experimentKey experiment',
      ({ experimentKey, value }) => {
        window.gon = () => {};

        gon.features = { [experimentUtils.featureFlagName(experimentKey)]: value };

        expect(experimentUtils.experimentEnabled(experimentKey)).toEqual(value);
      },
    );
  });
});
