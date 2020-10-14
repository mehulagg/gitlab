import { usageRatioToThresholdLevel } from 'ee/storage_counter/usage_thresholds';

describe('UsageThreshold', () => {
  it.each`
    usageRatio | expectedLevel
    ${0}       | ${'none'}
    ${0.4}     | ${'none'}
    ${0.5}     | ${'info'}
    ${0.9}     | ${'warning'}
    ${0.99}    | ${'alert'}
    ${1}       | ${'error'}
    ${1.5}     | ${'error'}
  `('returns $expectedLevel from $usageRatio', ({ usageRatio, expectedLevel }) => {
    expect(usageRatioToThresholdLevel(usageRatio)).toBe(expectedLevel);
  });
});
