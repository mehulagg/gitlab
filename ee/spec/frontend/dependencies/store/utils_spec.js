import listModule from 'ee/dependencies/store/modules/list';
import { addListType } from 'ee/dependencies/store/utils';

const mockModule = { mock: true };
jest.mock('ee/dependencies/store/modules/list', () => ({
  // `__esModule: true` is required when mocking modules with default exports:
  // https://jestjs.io/docs/en/jest-object#jestmockmodulename-factory-options
  __esModule: true,
  default: jest.fn(() => mockModule),
}));

describe('Dependencies store utils', () => {
  describe('addListType', () => {
    it('calls the correct store methods', () => {
      const store = {
        dispatch: jest.fn(),
        registerModule: jest.fn(),
      };

      const listType = {
        namespace: 'foo',
        initialState: { bar: true },
      };

      addListType(store, listType);

      expect(listModule).toHaveBeenCalled();
      expect(store.registerModule.mock.calls).toEqual([[listType.namespace, mockModule]]);
      expect(store.dispatch.mock.calls).toEqual([
        ['addListType', listType],
        [`${listType.namespace}/setInitialState`, listType.initialState],
      ]);
    });
  });
});
