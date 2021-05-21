import { shallowMount } from '@vue/test-utils';
import BoardFilteredSearch from '~/boards/components/board_filtered_search.vue';
import IssueBoardFilteredSpec from '~/boards/components/issue_board_filtered_search.vue';
import issueBoardFilters from '~/boards/issue_board_filters';
import { __ } from '~/locale';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';
import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';

describe('IssueBoardFilter', () => {
  let wrapper;

  const createComponent = ({ initialFilterParams = {} } = {}) => {
    wrapper = shallowMount(IssueBoardFilteredSpec, {
      provide: { initialFilterParams },
      props: { fullPath: '', boardType: '' },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('default', () => {
    beforeEach(() => {
      createComponent();
    });

    it('finds BoardFilteredSearch', () => {
      expect(wrapper.find(BoardFilteredSearch).exists()).toBe(true);
    });

    it.each([['group'], ['project']])(
      'when boradType is %s we pass the correct tokens to BoardFilteredSearch',
      (boardType) => {
        const { fetchAuthors, fetchLabels } = issueBoardFilters({}, '', boardType);
        const tokens = [
          {
            icon: 'labels',
            title: __('Label'),
            type: 'label_name',
            operators: [
              { value: '=', description: 'is' },
              { value: '!=', description: 'is not' },
            ],
            token: LabelToken,
            unique: false,
            symbol: '~',
            fetchLabels,
          },
          {
            icon: 'pencil',
            title: __('Author'),
            type: 'author_username',
            operators: [
              { value: '=', description: 'is' },
              { value: '!=', description: 'is not' },
            ],
            symbol: '@',
            token: AuthorToken,
            unique: true,
            fetchAuthors,
          },
          {
            icon: 'user',
            title: __('Assignee'),
            type: 'assignee_username',
            operators: [
              { value: '=', description: 'is' },
              { value: '!=', description: 'is not' },
            ],
            token: AuthorToken,
            unique: true,
            fetchAuthors,
          },
        ];

        expect(wrapper.find(BoardFilteredSearch).props('tokens').toString()).toBe(
          tokens.toString(),
        );
      },
    );
  });
});
