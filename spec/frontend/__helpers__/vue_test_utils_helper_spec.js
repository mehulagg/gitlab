import * as testingLibrary from '@testing-library/dom';
import * as vtu from '@vue/test-utils';
import {
  shallowMount,
  Wrapper as VTUWrapper,
  WrapperArray as VTUWrapperArray,
} from '@vue/test-utils';
import { extendedWrapper, shallowWrapperContainsSlotText } from './vue_test_utils_helper';

jest.mock('@testing-library/dom', () => ({
  __esModule: true,
  ...jest.requireActual('@testing-library/dom'),
}));

describe('Vue test utils helpers', () => {
  describe('shallowWrapperContainsSlotText', () => {
    const mockText = 'text';
    const mockSlot = `<div>${mockText}</div>`;
    let mockComponent;

    beforeEach(() => {
      mockComponent = shallowMount(
        {
          render(h) {
            h(`<div>mockedComponent</div>`);
          },
        },
        {
          slots: {
            default: mockText,
            namedSlot: mockSlot,
          },
        },
      );
    });

    it('finds text within shallowWrapper default slot', () => {
      expect(shallowWrapperContainsSlotText(mockComponent, 'default', mockText)).toBe(true);
    });

    it('finds text within shallowWrapper named slot', () => {
      expect(shallowWrapperContainsSlotText(mockComponent, 'namedSlot', mockText)).toBe(true);
    });

    it('returns false when text is not present', () => {
      const searchText = 'absent';

      expect(shallowWrapperContainsSlotText(mockComponent, 'default', searchText)).toBe(false);
      expect(shallowWrapperContainsSlotText(mockComponent, 'namedSlot', searchText)).toBe(false);
    });

    it('searches with case-sensitivity', () => {
      const searchText = mockText.toUpperCase();

      expect(shallowWrapperContainsSlotText(mockComponent, 'default', searchText)).toBe(false);
      expect(shallowWrapperContainsSlotText(mockComponent, 'namedSlot', searchText)).toBe(false);
    });
  });

  describe('extendedWrapper', () => {
    describe('when an invalid wrapper is provided', () => {
      beforeEach(() => {
        // eslint-disable-next-line no-console
        console.warn = jest.fn();
      });

      it.each`
        wrapper
        ${{}}
        ${[]}
        ${null}
        ${undefined}
        ${1}
        ${''}
      `('should warn with an error when the wrapper is $wrapper', ({ wrapper }) => {
        extendedWrapper(wrapper);
        /* eslint-disable no-console */
        expect(console.warn).toHaveBeenCalled();
        expect(console.warn).toHaveBeenCalledWith(
          '[vue-test-utils-helper]: you are trying to extend an object that is not a VueWrapper.',
        );
        /* eslint-enable no-console */
      });
    });

    describe.each`
      findMethod                 | expectedQuery
      ${`findByRole`}            | ${'queryByRole'}
      ${`findByLabelText`}       | ${'queryByLabelText'}
      ${`findByPlaceholderText`} | ${`queryByPlaceholderText`}
      ${`findByText`}            | ${`queryByText`}
      ${`findByDisplayValue`}    | ${`queryByDisplayValue`}
      ${`findByAltText`}         | ${`queryByAltText`}
      ${`findByTestId`}          | ${`queryByTestId`}
    `('$findMethod', ({ findMethod, expectedQuery }) => {
      const text = 'foo bar';
      const options = { selector: 'div' };
      const mockDiv = document.createElement('div');

      let wrapper;
      beforeEach(() => {
        wrapper = extendedWrapper(
          shallowMount({
            template: `<div>foo bar</div>`,
          }),
        );
      });

      it(`calls Testing Library \`${expectedQuery}\` function with correct parameters`, () => {
        jest.spyOn(testingLibrary, expectedQuery).mockImplementation(() => mockDiv);

        wrapper[findMethod](text, options);

        expect(testingLibrary[expectedQuery]).toHaveBeenLastCalledWith(
          wrapper.element,
          text,
          options,
        );
      });

      describe('when element is found', () => {
        beforeEach(() => {
          jest.spyOn(testingLibrary, expectedQuery).mockImplementation(() => mockDiv);
          jest.spyOn(vtu, 'createWrapper');
        });

        it('returns a VTU wrapper', () => {
          const result = wrapper[findMethod](text, options);

          expect(vtu.createWrapper).toHaveBeenCalledWith(mockDiv, wrapper.options);
          expect(result).toBeInstanceOf(VTUWrapper);
        });
      });

      describe('when element is not found', () => {
        beforeEach(() => {
          jest.spyOn(testingLibrary, expectedQuery).mockImplementation(() => null);
        });

        it('returns a VTU error wrapper', () => {
          expect(wrapper[findMethod](text, options).exists()).toBe(false);
        });
      });
    });

    describe.each`
      findMethod                    | expectedQuery
      ${`findAllByRole`}            | ${'queryAllByRole'}
      ${`findAllByLabelText`}       | ${'queryAllByLabelText'}
      ${`findAllByPlaceholderText`} | ${`queryAllByPlaceholderText`}
      ${`findAllByText`}            | ${`queryAllByText`}
      ${`findAllByDisplayValue`}    | ${`queryAllByDisplayValue`}
      ${`findAllByAltText`}         | ${`queryAllByAltText`}
      ${`findAllByTestId`}          | ${`queryAllByTestId`}
    `('$findMethod', ({ findMethod, expectedQuery }) => {
      const text = 'foo bar';
      const options = { selector: 'div' };
      const mockElements = [
        document.createElement('li'),
        document.createElement('li'),
        document.createElement('li'),
      ];

      let wrapper;
      beforeEach(() => {
        wrapper = extendedWrapper(
          shallowMount({
            template: `
              <ul>
                <li>foo</li>
                <li>bar</li>
                <li>baz</li>
              </ul>
            `,
          }),
        );
      });

      it(`calls Testing Library \`${expectedQuery}\` function with correct parameters`, () => {
        jest.spyOn(testingLibrary, expectedQuery).mockImplementation(() => mockElements);

        wrapper[findMethod](text, options);

        expect(testingLibrary[expectedQuery]).toHaveBeenLastCalledWith(
          wrapper.element,
          text,
          options,
        );
      });

      describe('when elements are found', () => {
        beforeEach(() => {
          jest.spyOn(testingLibrary, expectedQuery).mockImplementation(() => mockElements);
        });

        it('returns a VTU wrapper array', () => {
          const result = wrapper[findMethod](text, options);

          expect(result).toBeInstanceOf(VTUWrapperArray);
          expect(
            result.wrappers.every(
              (resultWrapper) =>
                resultWrapper instanceof VTUWrapper && resultWrapper.options === wrapper.options,
            ),
          ).toBe(true);
          expect(result.length).toBe(3);
        });
      });

      describe('when elements are not found', () => {
        beforeEach(() => {
          jest.spyOn(testingLibrary, expectedQuery).mockImplementation(() => []);
        });

        it('returns an empty VTU wrapper array', () => {
          const result = wrapper[findMethod](text, options);

          expect(result).toBeInstanceOf(VTUWrapperArray);
          expect(result.length).toBe(0);
        });
      });
    });
  });
});
