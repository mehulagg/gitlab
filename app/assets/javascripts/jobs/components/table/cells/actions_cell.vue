<script>
import { GlButton, GlButtonGroup } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlButtonGroup,
  },
  props: {
    job: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <gl-button-group>
    <gl-button icon="download"></gl-button>
    <gl-button icon="close"></gl-button>
    <gl-button icon="planning"></gl-button>
    <gl-button icon="play"></gl-button>
    <gl-button icon="time-out"></gl-button>
    <gl-button icon="repeat"></gl-button>
  </gl-button-group>
</template>
