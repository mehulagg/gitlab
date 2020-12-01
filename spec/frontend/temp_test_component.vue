<script>
import ChildComponent from './temp_child_component.vue';

export default {
  components: {
    ChildComponent,
  },
  data() {
    return {
      things: [{ foo: '123', bar: 'abc' }, { foo: '456', bar: 'def' }],
      loading: false,
    };
  },
  watch: {
    things(val) {
      console.log(val);
    },
  },
};
</script>
<template>
  <div>
    <child-component v-if="things.length" :things="things" :loading="loading" />
  </div>
</template>
