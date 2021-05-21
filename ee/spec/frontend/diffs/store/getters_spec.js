import * as getters from 'ee/diffs/store/getters';
import state from 'ee/diffs/store/modules/diff_state';

describe('EE Diffs Module Getters', () => {
  let localState;

  beforeEach(() => {
    localState = state();

    localState.codequalityDiff = {
      files: {
        'index.js': [
          {
            severity: 'minor',
            description: 'Unexpected alert.',
            line: 1,
          },
          {
            severity: 'major',
            description:
              'Function `aVeryLongFunction` has 52 lines of code (exceeds 25 allowed). Consider refactoring.',
            line: 3,
          },
          {
            severity: 'minor',
            description: 'Arrow function has too many statements (52). Maximum allowed is 30.',
            line: 3,
          },
        ],
      },
    };
  });

  describe('fileLineCodequality', () => {
    it.each`
      line | severity
      ${1} | ${'minor'}
      ${2} | ${'no'}
      ${3} | ${'major'}
      ${4} | ${'no'}
    `('finds $severity degradation on line $line', ({ line, severity }) => {
      if (severity === 'no') {
        expect(getters.fileLineCodequality(localState)('index.js', line)).toEqual([]);
      } else {
        expect(getters.fileLineCodequality(localState)('index.js', line)[0]).toMatchObject({
          line,
          severity,
        });
      }
    });
  });
});
