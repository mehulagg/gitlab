<script>
import {
  GlButton,
  GlFormRadio,
  GlFormRadioGroup,
  GlSearchBoxByType,
  GlSkeletonLoader,
} from '@gitlab/ui';
import { mapActions, mapGetters } from 'vuex';
import { fullLabelId } from '../boards_util';
import boardsStore from '../stores/boards_store';
import { __ } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

export default {
  i18n: {
    formDescription: __('A label list displays all issues with the selected label.'),
    searchPlaceholder: __('Search labels'),
  },
  components: {
    GlButton,
    GlFormRadio,
    GlFormRadioGroup,
    GlSearchBoxByType,
    GlSkeletonLoader,
  },
  data() {
    return {
      labels: [],
      loading: false,
      searchTerm: '',
      selectedLabelId: null,
    };
  },
  computed: {
    ...mapGetters(['getListByLabelId', 'shouldUseGraphQL']),
  },
  created() {
    this.filterLabels();
  },
  methods: {
    ...mapActions(['createList', 'fetchLabels', 'setAddColumnFormVisibility']),
    columnExists(label) {
      if (this.shouldUseGraphQL) {
        return Boolean(this.getListByLabelId(fullLabelId(label)));
      }
      return Boolean(boardsStore.findListByLabelId(label.id));
    },
    addList() {
      if (!this.selectedLabelId) {
        return;
      }

      if (this.shouldUseGraphQL) {
        if (this.columnExists({ id: this.selectedLabelId })) {
          return;
        }

        this.createList({ labelId: this.selectedLabelId });
      } else {
        const label = this.labels.find(({ id }) => id === this.selectedLabelId);
        const labelColumn = boardsStore.findListByLabelId(label.id);

        // if label doesn't exist or already has a column
        if (!label || labelColumn) {
          return;
        }

        boardsStore.new({
          title: label.title,
          position: boardsStore.state.lists.length - 2,
          list_type: 'label',
          label: {
            id: label.id,
            title: label.title,
            color: label.color,
          },
        });
      }
    },

    filterLabels() {
      this.loading = true;
      this.fetchLabels(this.searchTerm)
        .then((labels) => {
          if (this.shouldUseGraphQL) {
            this.labels = labels;
          } else {
            this.labels = labels.map((label) => {
              return {
                ...label,
                id: getIdFromGraphQLId(label.id),
              };
            });
          }
        })
        .catch((e) => {
          this.labels = [];
          this.error = __('Unable to load labels');
          throw e;
        })
        .finally(() => {
          this.loading = false;
        });
    },
  },
};
</script>

<template>
  <div
    class="board gl-display-inline-block gl-h-full gl-px-3 gl-vertical-align-top gl-white-space-normal is-expandable"
    data-qa-selector="board_add_new_list"
  >
    <div
      class="board-inner gl-display-flex gl-flex-direction-column gl-relative gl-h-full gl-rounded-base gl-bg-white"
    >
      <h3
        class="gl-font-base gl-px-5 gl-py-5 gl-m-0 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
      >
        {{ __('New label list') }}
      </h3>

      <div class="gl-display-flex gl-flex-direction-column gl-p-4 gl-h-full gl-overflow-hidden">
        <!-- selectbox is here in EE -->

        <p>{{ $options.i18n.formDescription }}</p>

        <gl-search-box-by-type
          v-model.trim="searchTerm"
          debounce="250"
          :placeholder="$options.i18n.searchPlaceholder"
          class="gl-mb-5"
          @input="filterLabels"
        />

        <gl-skeleton-loader v-if="loading" :width="500" :height="172">
          <rect width="480" height="20" x="10" y="15" rx="4" />
          <rect width="380" height="20" x="10" y="50" rx="4" />
          <rect width="430" height="20" x="10" y="85" rx="4" />
        </gl-skeleton-loader>

        <gl-form-radio-group v-else v-model="selectedLabelId" class="gl-overflow-y-auto">
          <label
            v-for="label in labels"
            :key="label.id"
            class="gl-display-flex gl-flex-align-items-center gl-mb-5 gl-font-weight-normal"
          >
            <gl-form-radio :value="label.id" class="gl-mb-0 gl-mr-3 gl-outline-0" />
            <span
              class="dropdown-label-box gl-top-0"
              :style="{
                backgroundColor: label.color,
              }"
            ></span>
            <span>{{ label.title }}</span>
          </label>
        </gl-form-radio-group>
      </div>

      <div
        class="gl-display-flex gl-p-3 gl-border-t-1 gl-border-t-solid gl-border-gray-100 gl-bg-gray-10"
      >
        <gl-button class="gl-ml-auto gl-mr-3" @click="setAddColumnFormVisibility(false)">{{
          __('Cancel')
        }}</gl-button>
        <gl-button variant="success" class="gl-mr-4" @click="addList">{{ __('Add') }}</gl-button>
      </div>
    </div>
  </div>
</template>
