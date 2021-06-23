<script>
import {
  GlButton,
  GlForm,
  GlFormInput,
  GlLoadingIcon,
  GlIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import { produce } from 'immer';
import createFlash from '~/flash';
import { __, s__, sprintf } from '~/locale';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';
import { weightQueries, MAX_DISPLAY_WEIGHT } from '../../constants';

export default {
  tracking: {
    event: 'click_edit_button',
    label: 'right_sidebar',
    property: 'weight',
  },
  components: {
    GlButton,
    GlForm,
    GlFormInput,
    GlIcon,
    GlLoadingIcon,
    SidebarEditableItem,
  },
  directives: {
    autofocusonshow,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    iid: {
      type: String,
      required: true,
    },
    fullPath: {
      type: String,
      required: true,
    },
    issuableType: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      weight: null,
      loading: false,
    };
  },
  apollo: {
    weight: {
      query() {
        return weightQueries[this.issuableType].query;
      },
      variables() {
        return {
          fullPath: this.fullPath,
          iid: String(this.iid),
        };
      },
      update(data) {
        return data.workspace?.issuable?.weight;
      },
      result({ data }) {
        this.$emit('weightUpdated', data.workspace?.issuable?.weight);
      },
      error() {
        createFlash({
          message: sprintf(__('Something went wrong while setting %{issuableType} weight.'), {
            issuableType: this.issuableType,
          }),
        });
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries?.weight?.loading || this.loading;
    },
    hasWeight() {
      return this.weight !== null;
    },
    tooltipTitle() {
      let tooltipTitle = s__('Sidebar|Weight');

      if (this.hasWeight) {
        tooltipTitle += ` ${this.weight}`;
      }

      return tooltipTitle;
    },
    collapsedWeightLabel() {
      return this.hasWeight ? this.weight.toString().substr(0, 5) : this.noValueLabel;
    },
    noValueLabel() {
      return s__('Sidebar|None');
    },
  },
  methods: {
    setWeight(remove) {
      const weight = remove ? null : this.weight;
      this.loading = true;
      this.$apollo
        .mutate({
          mutation: weightQueries[this.issuableType].mutation,
          variables: {
            input: {
              projectPath: this.fullPath,
              iid: this.iid,
              weight,
            },
          },
          update: (store) => {
            const queryProps = {
              query: weightQueries[this.issuableType].query,
              variables: {
                fullPath: this.fullPath,
                iid: String(this.iid),
              },
            };

            const sourceData = store.readQuery(queryProps);
            const data = produce(sourceData, (draftState) => {
              draftState.workspace.issuable.weight = weight;
            });
            store.writeQuery({
              data,
              ...queryProps,
            });
          },
        })
        .then(
          ({
            data: {
              issuableSetWeight: { errors },
            },
          }) => {
            if (errors.length) {
              createFlash({
                message: errors[0],
              });
            }
          },
        )
        .catch(() => {
          createFlash({
            message: sprintf(__('Something went wrong while setting %{issuableType} weight.'), {
              issuableType: this.issuableType,
            }),
          });
        })
        .finally(() => {
          this.loading = false;
        });
    },
    expandSidebar() {
      this.$refs.editable.expand();
      this.$emit('expandSidebar');
    },
    handleFormSubmit() {
      this.$refs.editable.collapse({ emitEvent: false });
      this.setWeight();
    },
  },
  i18n: {
    weight: __('Weight'),
    removeWeight: __('remove weight'),
    inputPlaceholder: __('Enter a number'),
  },
  maxDisplayWeight: MAX_DISPLAY_WEIGHT,
};
</script>

<template>
  <sidebar-editable-item
    ref="editable"
    :title="$options.i18n.weight"
    :tracking="$options.tracking"
    :loading="isLoading"
    class="block weight"
    data-testid="sidebar-weight"
    @close="setWeight()"
  >
    <template v-if="hasWeight" #collapsed>
      <div class="gl-display-flex gl-align-items-center hide-collapsed">
        <strong class="gl-text-gray-900" data-qa-selector="weight_label_value">{{ weight }}</strong>
        <span class="gl-mx-2">-</span>
        <gl-button
          variant="link"
          class="gl-text-gray-500!"
          data-testid="reset-button"
          :disabled="loading"
          @click="setWeight(true)"
        >
          {{ $options.i18n.removeWeight }}
        </gl-button>
      </div>
      <div
        v-gl-tooltip.left.viewport
        :title="tooltipTitle"
        class="sidebar-collapsed-icon js-weight-collapsed-block"
        @click="expandSidebar"
      >
        <gl-icon :size="16" name="weight" />
        <gl-loading-icon v-if="isLoading" class="js-weight-collapsed-loading-icon" />
        <span v-else class="js-weight-collapsed-weight-label">
          {{ collapsedWeightLabel }}
          <template v-if="weight > $options.maxDisplayWeight">&hellip;</template>
        </span>
      </div>
    </template>
    <template #default>
      <gl-form @submit.prevent="handleFormSubmit()">
        <gl-form-input
          v-model.number="weight"
          v-autofocusonshow
          type="number"
          min="0"
          :placeholder="$options.i18n.inputPlaceholder"
        />
      </gl-form>
    </template>
  </sidebar-editable-item>
</template>
