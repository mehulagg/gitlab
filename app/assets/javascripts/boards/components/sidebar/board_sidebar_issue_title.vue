<script>
import { mapGetters, mapActions } from 'vuex';
import { GlButton, GlForm, GlFormInput } from '@gitlab/ui';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';
import createFlash from '~/flash';
import { __ } from '~/locale';

export default {
  components: {
    GlForm,
    GlButton,
    GlFormInput,
    BoardEditableItem,
  },
  directives: {
    autofocusonshow,
  },
  data() {
    return {
      title: '',
      loading: false,
    };
  },
  computed: {
    ...mapGetters({ issue: 'getActiveIssue' }),

    projectPath() {
      const referencePath = this.issue.referencePath || '';
      return referencePath.slice(0, referencePath.indexOf('#'));
    },
  },
  watch: {
    issue: {
      handler(updatedIssue) {
        this.title = updatedIssue.title;
      },
      immediate: true,
    },
  },
  methods: {
    ...mapActions(['setActiveIssueTitle']),
    cancel() {
      this.title = this.issue.title;
      this.$refs.sidebarItem.collapse();
    },
    async setTitle() {
      this.$refs.sidebarItem.collapse();

      if (this.title === this.issue.title) {
        return;
      }

      try {
        this.loading = true;
        await this.setActiveIssueTitle({ title: this.title, projectPath: this.projectPath });
      } catch (e) {
        createFlash({ message: this.$options.i18n.updateTitleError });
      } finally {
        this.loading = false;
      }
    },
  },
  i18n: {
    issueTitlePlaceholder: __('Issue title'),
    submitButton: __('Save changes'),
    cancelButton: __('Cancel'),
    updateTitleError: __('An error occurred when updating the issue title'),
  },
};
</script>

<template>
  <board-editable-item ref="sidebarItem" :loading="loading" toggle-header>
    <template #title>
      <span class="gl-font-weight-bold" data-testid="issue-title">{{ issue.title }}</span>
    </template>
    <template #collapsed>
      <span class="gl-text-gray-800">{{ issue.referencePath }}</span>
    </template>
    <template>
      <gl-form @submit.prevent="setTitle">
        <gl-form-input
          v-model="title"
          v-autofocusonshow
          :placeholder="$options.i18n.issueTitlePlaceholder"
        />

        <div class="gl-display-flex gl-w-full gl-justify-content-space-between gl-mt-5">
          <gl-button variant="success" size="small" data-testid="submit-button" @click="setTitle">
            {{ $options.i18n.submitButton }}
          </gl-button>

          <gl-button size="small" data-testid="cancel-button" @click="cancel">
            {{ $options.i18n.cancelButton }}
          </gl-button>
        </div>
      </gl-form>
    </template>
  </board-editable-item>
</template>
