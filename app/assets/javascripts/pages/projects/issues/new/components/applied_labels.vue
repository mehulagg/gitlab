import { __ } from '~/locale';

<script>
export default {
  props: {
    target: {
      type: Element,
      required: false,
    },
  },
  data() {
    return {};
  },
  methods: {},
  mounted() {
    console.log('Mounted::js-applied-labels');
    console.log('Mounted::target', this.target);
  },
};
</script>
<template>
  <div>
    <p>Nice</p>
  </div>
</template>
