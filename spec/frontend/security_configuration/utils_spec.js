import {
  securityFeatures,
  complianceFeatures,
} from '~/security_configuration/components/constants';

import { augmentFeatures } from '~/security_configuration/utils';

const mockData = {
  securityFeatures,
  complianceFeatures,
};

describe('augmentFeatures', () => {
  it('augments features array correctly when given an empty array', () => {
    expect(augmentFeatures()).toStrictEqual(mockData);
  });

  it('returns false when given a non-array invalid input', () => {
    // eslint-disable-next-line array-callback-return
    ['', false, true, {}].map((e) => {
      expect(augmentFeatures(e)).toBe(false);
    });
  });

  // TODO 'augments features array correctly when given a populated array', () => {
});
