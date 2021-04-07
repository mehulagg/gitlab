import * as getters from 'ee/diffs/store/getters';
import state from 'ee/diffs/store/modules/diff_state';

describe('EE Diffs Module Getters', () => {
  let localState;

  beforeEach(() => {
    localState = state();
  });

  describe('getDiffFileCodequality', () => {
    beforeEach(() => {
      Object.assign(localState.codequalityDiff, {
        files: { 'app.js': [{ line: 1, description: 'Unexpected alert.', severity: 'minor' }] },
      });
    });

    it('returns empty array when no codequality data is available', () => {
      Object.assign(localState.codequalityDiff, {});

      expect(getters.getDiffFileCodequality(localState)('test.js')).toEqual([]);
    });

    it('returns array when codequality data is available for given file', () => {
      expect(getters.getDiffFileCodequality(localState)('app.js')).toEqual([
        { line: 1, description: 'Unexpected alert.', severity: 'minor' },
      ]);
    });
  });
});
