<script>
import { mapGetters, mapActions } from 'vuex';
import { GlButton, GlForm, GlFormInput } from '@gitlab/ui';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';
import createFlash from '~/flash';
import { __ } from '~/locale';

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
    ...mapGetters(['activeIssue', 'projectPathForActiveIssue']),
    hasWeight() {
      return this.activeIssue.weight > 0;
    },
  },
  watch: {
    activeIssue: {
      handler(updatedIssue) {
        this.weight = updatedIssue.weight;
      },
      immediate: true,
    },
  },
  methods: {
    ...mapActions(['setActiveIssueWeight']),
    handleFormSubmit() {
      this.$refs.sidebarItem.collapse({ emitEvent: false });
      this.setWeight();
    },
    async setWeight(provided) {
      const weight = provided ?? this.weight;

      if (this.loading || weight === this.activeIssue.weight) {
        return;
      }

      this.loading = true;

      try {
        await this.setActiveIssueWeight({ weight, projectPath: this.projectPathForActiveIssue });
        this.weight = weight;
      } catch (e) {
        this.weight = this.activeIssue.weight;
        createFlash({ message: __('An error occurred when updating the issue weight') });
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
    @close="setWeight()"
  >
    <template v-if="hasWeight" #collapsed>
      <div class="gl-display-flex gl-align-items-center">
        <strong class="gl-text-gray-900">{{ activeIssue.weight }}</strong>
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
