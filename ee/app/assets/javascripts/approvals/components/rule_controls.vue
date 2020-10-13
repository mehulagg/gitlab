<script>
import { mapState, mapActions } from 'vuex';
import { GlButton, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlIcon,
  },
  props: {
    rule: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapState(['settings']),
  },
  methods: {
    ...mapActions(['requestEditRule', 'requestDeleteRule']),
  },
};
</script>

<template>
  <div>
    <gl-button @click="requestEditRule(rule)">
      <span>{{ __('Edit') }}</span>
    </gl-button>
    <gl-button
      class="gl-ml-3 btn btn-inverted"
      variant="danger"
      category="primary"
      @click="requestDeleteRule(rule)"
    >
      <gl-icon name="remove" :aria-label="__('Remove')" />
    </gl-button>
  </div>
</template>
