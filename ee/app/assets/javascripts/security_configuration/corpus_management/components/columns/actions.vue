<script>
import { GlButton, GlModal, GlModalDirective } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlModal,
  },
  directives: {
    GlModalDirective,
  },
  props: {
    corpus: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      showConfirmationModal: false,
    };
  },
  modal: {
    actionPrimary: {
      text: s__('Delete'),
      attributes: { variant: 'danger', 'data-testid': 'modal-confirm' },
    },
    actionCancel: {
      text: s__('Cancel'),
    },
  },
  computed: {
    downloadPath() {
      // TODO: Replace with relative path when we complete backend
      return `https://www.gitlab.com/${this.corpus.downloadPath}`;
    },
    deleteCorpusMessage() {
      return s__('Corpus Management|Are you sure you want to delete the corpus?');
    },
  },
  methods: {
    deleteCorpus() {
      this.$emit('delete', this.corpus);
    },
  },
};
</script>
<template>
  <span>
    <gl-button
      class="gl-mr-2"
      icon="download"
      category="secondary"
      variant="confirm"
      :href="downloadPath"
    />
    <gl-button
      v-gl-modal-directive="`confirmation-modal-${corpus.name}`"
      icon="remove"
      category="secondary"
      variant="danger"
    />

    <gl-modal
      header-class="gl-border-b-initial"
      body-class="gl-display-none"
      size="sm"
      :modal-id="`confirmation-modal-${corpus.name}`"
      :action-primary="$options.modal.actionPrimary"
      :action-cancel="$options.modal.actionCancel"
      @primary="deleteCorpus"
    >
      <template #modal-title>
        {{ deleteCorpusMessage }}
      </template>
    </gl-modal>
  </span>
</template>
