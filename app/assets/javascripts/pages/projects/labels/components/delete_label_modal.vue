<script>
import { GlModal } from '@gitlab/ui';
import { sprintf, s__, __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';

export default {
  components: {
    GlModal,
  },
  props: {
    labelName: {
      type: String,
      required: true,
    },
    subjectName: {
      type: String,
      required: true,
    },
    deleteLabelPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    deleteMessage() {
      return sprintf(
        s__(
          'Labels|%{labelName} will be permanently deleted from %{subjectName}. This cannot be undone',
        ),
        {
          labelName: this.labelName,
          subjectName: this.subjectName,
        },
      );
    },
  },
  methods: {
    onSubmit() {
      return axios
        .delete(this.deleteLabelPath, { params: { format: 'json' } })
        .then(resp => resp.data) // TODO: Do something with the returned data
        .catch(error => {
          createFlash({ message: error });
        });
    },
  },
  primaryProps: {
    text: s__('Labels|Delete Label'),
    attributes: [{ variant: 'danger' }, { category: 'primary' }],
  },
  cancelProps: {
    text: __('Cancel'),
  },
};
</script>
<template>
  <gl-modal
    modal-id="delete-label-modal"
    :action-primary="$options.primaryProps"
    :action-cancel="$options.cancelProps"
    @primary="onSubmit"
  >
    {{ deleteMessage }}
  </gl-modal>
</template>
