<script>
import { GlButton, GlForm, GlFormInput } from '@gitlab/ui';
import { mapGetters, mapActions } from 'vuex';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import { __ } from '~/locale';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';

export default {
  components: {
    BoardEditableItem,
    GlForm,
    GlButton,
    GlFormInput,
  },
  directives: {
    autofocusonshow,
  },
  data() {
    return {
      weight: null,
      loading: false,
    };
  },
  computed: {
    ...mapGetters(['activeBoardItem', 'projectPathForActiveIssue']),
    hasWeight() {
      return this.activeBoardItem.weight > 0;
    },
  },
  watch: {
    activeBoardItem: {
      handler(updatedIssue) {
        this.weight = updatedIssue.weight;
      },
      immediate: true,
    },
  },
  methods: {
    ...mapActions(['setActiveIssueWeight', 'setError']),
    handleFormSubmit() {
      this.$refs.sidebarItem.collapse({ emitEvent: false });
      this.setWeight();
    },
    async setWeight(provided) {
      const weight = provided ?? this.weight;

      if (this.loading || weight === this.activeBoardItem.weight) {
        return;
      }

      this.loading = true;

      try {
        await this.setActiveIssueWeight({ weight, projectPath: this.projectPathForActiveIssue });
        this.weight = weight;
      } catch (e) {
        this.weight = this.activeBoardItem.weight;
        this.setError({ message: __('An error occurred when updating the issue weight') });
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<template>
  <board-editable-item
    ref="sidebarItem"
    :title="__('Weight')"
    :loading="loading"
    data-testid="sidebar-weight"
    @close="setWeight()"
  >
    <template v-if="hasWeight" #collapsed>
      <div class="gl-display-flex gl-align-items-center">
        <strong
          class="gl-text-gray-900 js-weight-weight-label-value"
          data-qa-selector="weight_label_value"
          >{{ activeBoardItem.weight }}</strong
        >
        <span class="gl-mx-2">-</span>
        <gl-button
          variant="link"
          class="gl-text-gray-500!"
          data-testid="reset-button"
          :disabled="loading"
          @click="setWeight(0)"
        >
          {{ __('remove weight') }}
        </gl-button>
      </div>
    </template>
    <gl-form @submit.prevent="handleFormSubmit()">
      <gl-form-input
        v-model.number="weight"
        v-autofocusonshow
        type="number"
        min="0"
        :placeholder="__('Enter a number')"
      />
    </gl-form>
  </board-editable-item>
</template>
