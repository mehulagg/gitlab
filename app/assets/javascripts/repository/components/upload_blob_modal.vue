<script>
import { GlModal } from '@gitlab/ui';

export default {
  components: {
    GlModal,
  },
};
</script>
<template>
  <gl-modal modal-id="some-unqiue-modal-id" title="Such">
    {{ 'Content' }}
  </gl-modal>
</template>
