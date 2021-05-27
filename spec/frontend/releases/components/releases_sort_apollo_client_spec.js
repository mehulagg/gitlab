import { GlSorting, GlSortingItem } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ReleasesSortApolloclient from '~/releases/components/releases_sort_apollo_client.vue';
import { RELEASED_AT_ASC, RELEASED_AT_DESC, CREATED_ASC, CREATED_DESC } from '~/releases/constants';

describe('releases_sort_apollo_client.vue', () => {
  let wrapper;
  let onInput;

  const createComponent = (valueProp = RELEASED_AT_ASC) => {
    onInput = jest.fn();

    wrapper = shallowMountExtended(ReleasesSortApolloclient, {
      propsData: {
        value: valueProp,
      },
      listeners: {
        input: onInput,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findSorting = () => wrapper.findComponent(GlSorting);
  const findSortingItems = () => wrapper.findAllComponents(GlSortingItem);
  const findReleasedDateItem = () =>
    findSortingItems().wrappers.find((item) => item.text() === 'Released date');
  const getSortingItemsInfo = () =>
    findSortingItems().wrappers.map((item) => ({
      label: item.text(),
      active: item.attributes().active === 'true',
    }));

  describe.each`
    valueProp           | text               | isAscending | items
    ${RELEASED_AT_ASC}  | ${'Released date'} | ${true}     | ${[{ label: 'Released date', active: true }, { label: 'Created date', active: false }]}
    ${RELEASED_AT_DESC} | ${'Released date'} | ${false}    | ${[{ label: 'Released date', active: true }, { label: 'Created date', active: false }]}
    ${CREATED_ASC}      | ${'Created date'}  | ${true}     | ${[{ label: 'Released date', active: false }, { label: 'Created date', active: true }]}
    ${CREATED_DESC}     | ${'Created date'}  | ${false}    | ${[{ label: 'Released date', active: false }, { label: 'Created date', active: true }]}
  `('component states', ({ valueProp, text, isAscending, items }) => {
    beforeEach(() => {
      createComponent(valueProp);
    });

    it(`when the sort is ${valueProp}, provides the GlSorting with the props text="${text}" and isAscending=${isAscending}`, () => {
      expect(findSorting().props()).toEqual(
        expect.objectContaining({
          text,
          isAscending,
        }),
      );
    });

    it(`when the sort is ${valueProp}, renders the expected dropdown items`, () => {
      expect(getSortingItemsInfo()).toEqual(items);
    });
  });

  describe.each`
    valueProp           | releasedAt         | createdAt       | ascending           | descending
    ${RELEASED_AT_ASC}  | ${undefined}       | ${CREATED_ASC}  | ${undefined}        | ${RELEASED_AT_DESC}
    ${RELEASED_AT_DESC} | ${undefined}       | ${CREATED_DESC} | ${RELEASED_AT_DESC} | ${undefined}
    ${CREATED_ASC}      | ${RELEASED_AT_ASC} | ${undefined}    | ${undefined}        | ${CREATED_DESC}
  `('input event', ({ valueProp, releasedAt, createdAt, ascending, descending }) => {
    beforeEach(() => {
      createComponent(valueProp);
    });

    describe('when the "Released date" sort is selected', () => {
      const testDescription = releasedAt
        ? 'emits no input event'
        : `emits an input event with param ${releasedAt}`;

      it(testDescription, async () => {
        console.log(findReleasedDateItem());
        findReleasedDateItem().$emit('click');
        await wrapper.vm.$nextTick();
        expect(onInput.mock.calls[0]).toEqual(releasedAt);
      });
    });
  });
});
