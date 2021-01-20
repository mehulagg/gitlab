<script>
import { GlButton, GlFormRadio, GlFormRadioGroup, GlSearchBoxByType } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { __ } from '~/locale';

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
  },
  data() {
    return {
      searchTerm: '',
      selectedLabel: null,
      labels: [],
    };
  },
  created() {
    this.filterLabels();
  },
  methods: {
    ...mapActions(['fetchLabels']),
    filterLabels() {
      this.fetchLabels(this.searchTerm)
        .then((labels) => {
          this.labels = labels;
        })
        .catch((e) => {
          this.labels = [];
          this.error = __('Unable to load labels or something');
          throw e;
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
      class="board-inner gl-display-flex gl-flex-direction-column gl-relative gl-h-full gl-rounded-base"
    >
      <h4 class="gl-px-3 gl-pb-3 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100">
        {{ __('New label list') }}
      </h4>

      <div class="gl-display-flex gl-flex-direction-column gl-p-4 gl-h-full gl-overflow-hidden">
        <!-- selectbox is here in EE -->

        <p>{{ $options.i18n.formDescription }}</p>

        <gl-search-box-by-type
          v-model.trim="searchTerm"
          debounce="250"
          :placeholder="$options.i18n.searchPlaceholder"
          class="gl-mb-4"
          @input="filterLabels"
        />

        <gl-form-radio-group class="gl-overflow-y-auto gl-mr-n4">
          <label v-for="label in labels" :key="label.id" class="gl-display-flex">
            <gl-form-radio v-model="selectedLabel" />
            <span
              class="dropdown-label-box"
              :style="{
                backgroundColor: label.color,
              }"
            ></span>
            <span>{{ label.title }}</span>
          </label>
        </gl-form-radio-group>
      </div>

      <div class="gl-display-flex gl-p-3 gl-border-t-1 gl-border-t-solid gl-border-gray-100">
        <gl-button class="gl-ml-auto gl-mr-4">{{ __('Cancel') }}</gl-button>
        <gl-button variant="success" class="gl-mr-4">{{ __('Add') }}</gl-button>
      </div>
    </div>
  </div>
</template>
