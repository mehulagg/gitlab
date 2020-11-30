import { shallowMount } from '@vue/test-utils';
import { GlPagination } from '@gitlab/ui';
import Component from '~/registry/explorer/components/list_page/image_list.vue';
import ImageListRow from '~/registry/explorer/components/list_page/image_list_row.vue';

import { imagesListResponse, pageInfo as defaultPageInfo } from '../../mock_data';

describe('Image List', () => {
  let wrapper;

  const findRow = () => wrapper.findAll(ImageListRow);
  const findPagination = () => wrapper.find(GlPagination);

  const mountComponent = (pageInfo = defaultPageInfo) => {
    wrapper = shallowMount(Component, {
      propsData: {
        images: imagesListResponse,
        pageInfo,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('list', () => {
    it('contains one list element for each image', () => {
      mountComponent();

      expect(findRow().length).toBe(imagesListResponse.length);
    });

    it('when delete event is emitted on the row it emits up a delete event', () => {
      mountComponent();

      findRow()
        .at(0)
        .vm.$emit('delete', 'foo');
      expect(wrapper.emitted('delete')).toEqual([['foo']]);
    });
  });

  describe('pagination', () => {
    it('exists', () => {
      mountComponent();

      expect(findPagination().exists()).toBe(true);
    });

    it.each`
      hasNextPage | hasPreviousPage | isVisible
      ${true}     | ${true}         | ${true}
      ${true}     | ${false}        | ${true}
      ${false}    | ${true}         | ${true}
    `(
      'when hasNextPage is $hasNextPage and hasPreviousPage is $hasPreviousPage: is $isVisible that the component is visible',
      ({ hasNextPage, hasPreviousPage, isVisible }) => {
        mountComponent({ hasNextPage, hasPreviousPage });

        expect(findPagination().exists()).toBe(isVisible);
      },
    );

    it.each`
      hasNextPage | hasPreviousPage | nextPage | previousPage | currentPage
      ${true}     | ${true}         | ${2}     | ${1}         | ${2}
      ${true}     | ${false}        | ${2}     | ${null}      | ${1}
      ${false}    | ${true}         | ${null}  | ${1}         | ${2}
    `(
      'when hasNextPage is $hasNextPage and hasPreviousPage is $hasPreviousPage: nextPage is $nextPage, previousPage is $previousPage and currentPage is $currentPage',
      ({ hasNextPage, hasPreviousPage, nextPage, previousPage, currentPage }) => {
        mountComponent({ hasNextPage, hasPreviousPage });

        const pagination = findPagination();
        expect(pagination.props('prevPage')).toBe(previousPage);
        expect(pagination.props('nextPage')).toBe(nextPage);
        expect(pagination.props('value')).toBe(currentPage);
      },
    );

    it('emits "prev-page" when the user clicks the back page button', () => {
      mountComponent({ hasPreviousPage: true });

      findPagination().vm.$emit(GlPagination.model.event, 1);

      expect(wrapper.emitted('prev-page')).toEqual([[]]);
    });

    it('emits "next-page" when the user clicks the forward page button', () => {
      mountComponent({ hasNextPage: true });

      findPagination().vm.$emit(GlPagination.model.event, 2);

      expect(wrapper.emitted('next-page')).toEqual([[]]);
    });
  });
});
