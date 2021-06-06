<script>
const TEMPORARY_PLACEHOLDER = 'Placeholder for responsive top nav';

export default {
  props: {
    navData: {
      type: Object,
      required: true,
    },
  },
  TEMPORARY_PLACEHOLDER,
};
</script>

<template>
  <p>{{ $options.TEMPORARY_PLACEHOLDER }}</p>
</template>
