<script>
import { uniqueId } from 'lodash';

export default {
  created() {
    this.uniqueId = uniqueId('accordion-');
  },
};
</script>
<template>
  <div>
    <ul class="list-group list-group-flush py-2">
      <slot :accordion-id="uniqueId"></slot>
    </ul>
  </div>
</template>
