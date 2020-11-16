<script>
export default {
  name: 'DevopsAdoptionTableCellFlag',
  props: {
    enabled: {
      type: Boolean,
      required: true,
    },
  },
};
</script>
<template>
  <span class="circle" :class="{ 'circle-enabled': enabled }"></span>
</template>
