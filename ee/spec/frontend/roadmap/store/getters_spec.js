import { PRESET_TYPES } from 'ee/roadmap/constants';
import * as getters from 'ee/roadmap/store/getters';

describe('Roadmap Store Getters', () => {
  describe('lastTimeframeIndex', () => {
    it('Should return last index of the timeframe array from state', () => {
      const roadmapState = {
        timeframe: [1, 2, 3, 4],
      };

      expect(getters.lastTimeframeIndex(roadmapState)).toBe(3);
    });
  });

  describe('timeframeStartDate', () => {
    it('Should return first item of the timeframe range array from the state when preset type is Quarters', () => {
      const roadmapState = {
        timeframe: [{ range: ['foo', 'bar', 'baz'] }, { range: ['abc', 'cde', 'efg'] }],
        presetType: PRESET_TYPES.QUARTERS,
      };

      expect(getters.timeframeStartDate(roadmapState)).toBe('foo');
    });

    it('Should return first item of the timeframe array from the state when preset type is Months or Weeks', () => {
      const roadmapState = {
        timeframe: ['foo', 'bar', 'baz'],
        presetType: PRESET_TYPES.MONTHS,
      };

      expect(getters.timeframeStartDate(roadmapState)).toBe('foo');

      roadmapState.presetType = PRESET_TYPES.WEEKS;

      expect(getters.timeframeStartDate(roadmapState)).toBe('foo');
    });
  });

  describe('timeframeEndDate', () => {
    it('Should return last item of the timeframe range array from the state when preset type is Quarters', () => {
      const roadmapState = {
        timeframe: [{ range: ['foo', 'bar', 'baz'] }, { range: ['abc', 'cde', 'efg'] }],
        presetType: PRESET_TYPES.QUARTERS,
      };

      expect(
        getters.timeframeEndDate(roadmapState, {
          lastTimeframeIndex: roadmapState.timeframe.length - 1,
        }),
      ).toBe('efg');
    });

    it('Should return last item of the timeframe array from the state when preset type is Months', () => {
      const roadmapState = {
        timeframe: ['foo', 'bar', 'baz'],
        presetType: PRESET_TYPES.MONTHS,
      };

      expect(
        getters.timeframeEndDate(roadmapState, {
          lastTimeframeIndex: roadmapState.timeframe.length - 1,
        }),
      ).toBe('baz');
    });

    it('Should return last item of the timeframe array from the state when preset type is Weeks', () => {
      const roadmapState = {
        timeframe: [new Date(2018, 11, 23), new Date(2018, 11, 30), new Date(2019, 0, 6)],
        presetType: PRESET_TYPES.WEEKS,
      };

      expect(
        getters
          .timeframeEndDate(roadmapState, {
            lastTimeframeIndex: roadmapState.timeframe.length - 1,
          })
          .getTime(),
      ).toBe(new Date(2019, 0, 13).getTime());
    });
  });
});
