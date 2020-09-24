import * as getters from 'ee/dependencies/store/getters';

describe('Dependencies getters', () => {
  describe.each`
    getterName         | propertyName
    ${'isInitialized'} | ${'initialized'}
    ${'reportInfo'}    | ${'reportInfo'}
  `('$getterName', ({ getterName, propertyName }) => {
    it(`returns the value from the current list module's state`, () => {
      const mockValue = {};
      const state = {
        listFoo: {
          [propertyName]: mockValue,
        },
        currentList: 'listFoo',
      };

      expect(getters[getterName](state)).toBe(mockValue);
    });
  });

  describe.each`
    getterName
    ${'isJobNotSetUp'}
    ${'isJobFailed'}
    ${'isIncomplete'}
    ${'hasNoDependencies'}
    ${'generatedAtTimeAgo'}
  `('$getterName', ({ getterName }) => {
    it(`delegates to the current list module's ${getterName} getter`, () => {
      const mockValue = {};
      const currentList = 'fooList';
      const state = { currentList };
      const rootGetters = {
        [`${currentList}/${getterName}`]: mockValue,
      };

      expect(getters[getterName](state, rootGetters)).toBe(mockValue);
    });
  });

  describe('totals', () => {
    it('returns a map of list module namespaces to total counts', () => {
      const state = {
        listTypes: [
          { namespace: 'foo' },
          { namespace: 'bar' },
          { namespace: 'qux' },
          { namespace: 'foobar' },
        ],
        foo: { pageInfo: { total: 1 } },
        bar: { pageInfo: { total: 2 } },
        qux: { pageInfo: { total: NaN } },
        foobar: { pageInfo: {} },
      };

      expect(getters.totals(state)).toEqual({
        foo: 1,
        bar: 2,
        qux: 0,
        foobar: 0,
      });
    });
  });
});
