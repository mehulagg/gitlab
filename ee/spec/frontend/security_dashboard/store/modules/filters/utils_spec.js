import { ALL } from 'ee/security_dashboard/store/modules/filters/constants';
import { hasValidSelection, setFilter } from 'ee/security_dashboard/store/modules/filters/utils';

describe('filters module utils', () => {
  describe('hasValidSelection', () => {
    describe.each`
      selection         | options           | expected
      ${[]}             | ${[]}             | ${true}
      ${[]}             | ${['foo']}        | ${true}
      ${['foo']}        | ${['foo']}        | ${true}
      ${['foo']}        | ${['foo', 'bar']} | ${true}
      ${['bar', 'foo']} | ${['foo', 'bar']} | ${true}
      ${['foo']}        | ${[]}             | ${false}
      ${['foo']}        | ${['bar']}        | ${false}
      ${['foo', 'bar']} | ${['foo']}        | ${false}
    `('given selection $selection and options $options', ({ selection, options, expected }) => {
      let filter;
      beforeEach(() => {
        filter = {
          selection,
          options: options.map(id => ({ id })),
        };
      });

      it(`return ${expected}`, () => {
        expect(hasValidSelection(filter)).toBe(expected);
      });
    });
  });

  describe('setFilter', () => {
    const filterId = 'foo';
    const option1 = 'bar';
    const option2 = 'baz';
    const initFilters = (initiallySelected = [ALL]) => [
      { id: filterId, selection: new Set(initiallySelected) },
    ];
    let filters;
    let filter;

    describe('when ALL is initially selected', () => {
      beforeEach(() => {
        filters = initFilters();
      });

      describe('when a valid filter is passed', () => {
        beforeEach(() => {
          [filter] = setFilter(filters, { filterId, optionId: option1 });
        });

        it('should select the passed option', () => {
          expect(filter.selection.has(option1)).toBe(true);
        });

        it('should remove the `ALL` option', () => {
          expect(filter.selection.has(ALL)).toBe(false);
        });
      });

      describe('when an invalid filter is passed ', () => {
        beforeEach(() => {
          [filter] = setFilter(filters, { filterId: 'baz', optionId: option1 });
        });

        it('should not select the passed option', () => {
          expect(filter.selection.has(option1)).toBe(false);
        });

        it('should not remove the `ALL` option', () => {
          expect(filter.selection.has(ALL)).toBe(true);
        });
      });
    });

    describe('when an option is initially selected', () => {
      beforeEach(() => {
        filters = initFilters([option1]);
      });

      describe('when the selected option is passed', () => {
        beforeEach(() => {
          [filter] = setFilter(filters, { filterId, optionId: option1 });
        });

        it('should remove the passed option', () => {
          expect(filter.selection.has(option1)).toBe(false);
        });

        it('should select the `ALL` option', () => {
          expect(filter.selection.has(ALL)).toBe(true);
        });
      });

      describe('when another option is passed ', () => {
        beforeEach(() => {
          [filter] = setFilter(filters, { filterId, optionId: option2 });
        });

        it('should not remove the initially selected option', () => {
          expect(filter.selection.has(option1)).toBe(true);
        });

        it('should add the passed selected option', () => {
          expect(filter.selection.has(option2)).toBe(true);
        });

        it('should not select the `ALL` option', () => {
          expect(filter.selection.has(ALL)).toBe(false);
        });
      });
    });

    describe('when two options are initially selected', () => {
      beforeEach(() => {
        filters = initFilters([option1, option2]);
      });

      describe('when a selected option is passed', () => {
        beforeEach(() => {
          [filter] = setFilter(filters, { filterId, optionId: option1 });
        });

        it('should remove the passed option', () => {
          expect(filter.selection.has(option1)).toBe(false);
        });

        it('should not remove the other option', () => {
          expect(filter.selection.has(option2)).toBe(true);
        });

        it('should not select the `ALL` option', () => {
          expect(filter.selection.has(ALL)).toBe(false);
        });
      });
    });
  });
});
