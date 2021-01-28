import { GlFilteredSearchToken } from '@gitlab/ui';

import { __ } from '~/locale';
import Api from '~/api';
import axios from '~/lib/utils/axios_utils';

import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';
import MilestoneToken from '~/vue_shared/components/filtered_search_bar/tokens/milestone_token.vue';

import { FilterTokenOperators } from '../constants';

export default {
  inject: ['groupFullPath', 'groupMilestonesPath'],
  computed: {
    urlParams() {
      const { search, authorUsername, labelName, milestoneTitle, confidential } =
        this.filterParams || {};

      return {
        state: this.currentState || this.epicsState,
        page: this.currentPage,
        sort: this.sortedBy,
        prev: this.prevPageCursor || undefined,
        next: this.nextPageCursor || undefined,
        author_username: authorUsername,
        'label_name[]': labelName,
        milestone_title: milestoneTitle,
        confidential,
        search,
      };
    },
  },
  methods: {
    getFilteredSearchTokens() {
      return [
        {
          type: 'author_username',
          icon: 'user',
          title: __('Author'),
          unique: true,
          symbol: '@',
          token: AuthorToken,
          operators: FilterTokenOperators,
          fetchAuthors: Api.users.bind(Api),
        },
        {
          type: 'label_name',
          icon: 'labels',
          title: __('Label'),
          unique: false,
          symbol: '~',
          token: LabelToken,
          operators: FilterTokenOperators,
          fetchLabels: (search = '') => {
            const params = {
              only_group_labels: true,
              include_ancestor_groups: true,
              include_descendant_groups: true,
            };

            if (search) {
              params.search = search;
            }

            return Api.groupLabels(this.groupFullPath, {
              params,
            });
          },
        },
        {
          type: 'milestone_title',
          icon: 'clock',
          title: __('Milestone'),
          unique: true,
          symbol: '%',
          token: MilestoneToken,
          operators: FilterTokenOperators,
          fetchMilestones: (search = '') => {
            return axios.get(this.groupMilestonesPath).then(({ data }) => {
              // TODO: Remove below condition check once either of the following is supported.
              // a) Milestones Private API supports search param.
              // b) Milestones Public API supports including child projects' milestones.
              if (search) {
                return {
                  data: data.filter((m) => m.title.toLowerCase().includes(search.toLowerCase())),
                };
              }
              return { data };
            });
          },
        },
        {
          type: 'confidential',
          icon: 'eye-slash',
          title: __('Confidential'),
          unique: true,
          token: GlFilteredSearchToken,
          operators: FilterTokenOperators,
          options: [
            { icon: 'eye-slash', value: true, title: __('Yes') },
            { icon: 'eye', value: false, title: __('No') },
          ],
        },
      ];
    },
    getFilteredSearchValue() {
      const { authorUsername, labelName, milestoneTitle, confidential, search } =
        this.filterParams || {};
      const filteredSearchValue = [];

      if (authorUsername) {
        filteredSearchValue.push({
          type: 'author_username',
          value: { data: authorUsername },
        });
      }

      if (labelName?.length) {
        filteredSearchValue.push(
          ...labelName.map((label) => ({
            type: 'label_name',
            value: { data: label },
          })),
        );
      }

      if (milestoneTitle) {
        filteredSearchValue.push({
          type: 'milestone_title',
          value: { data: milestoneTitle },
        });
      }

      if (confidential !== undefined) {
        filteredSearchValue.push({
          type: 'confidential',
          value: { data: confidential },
        });
      }

      if (search) {
        filteredSearchValue.push(search);
      }

      return filteredSearchValue;
    },
    getFilterParams(filters = []) {
      const filterParams = {};
      const labels = [];
      const plainText = [];

      filters.forEach((filter) => {
        switch (filter.type) {
          case 'author_username':
            filterParams.authorUsername = filter.value.data;
            break;
          case 'label_name':
            labels.push(filter.value.data);
            break;
          case 'milestone_title':
            filterParams.milestoneTitle = filter.value.data;
            break;
          case 'confidential':
            filterParams.confidential = filter.value.data;
            break;
          case 'filtered-search-term':
            if (filter.value.data) plainText.push(filter.value.data);
            break;
          default:
            break;
        }
      });

      if (labels.length) {
        filterParams.labelName = labels;
      }

      if (plainText.length) {
        filterParams.search = plainText.join(' ');
      }

      return filterParams;
    },
  },
};
