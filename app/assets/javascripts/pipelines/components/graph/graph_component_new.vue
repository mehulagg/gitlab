<script>
import { performanceMarkAndMeasure } from '../../../performance/utils.js';

export default {
  mounted() {
    performanceMarkAndMeasure({
      mark: 'NEW_GRAPH_LOADED',
    });
  }
};
</script>
<template>
  <div>
    hi
  </div>
</template>
