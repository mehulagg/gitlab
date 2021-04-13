<script>
import List from './types/list.vue';
import Url from './types/url.vue';

export default {
  components: {
    List,
    Url,
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <component :is="item.type" v-bind="item" data-testid="reportComponent" />
</template>
