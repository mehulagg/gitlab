<script>
import NamedList from './types/named_list.vue';
import Url from './types/url.vue';

export default {
  components: {
    Url,
    NamedList,
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
