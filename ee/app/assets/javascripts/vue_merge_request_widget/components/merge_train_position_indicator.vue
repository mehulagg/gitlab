<script>
import { s__, sprintf } from '~/locale';

export default {
  name: 'MergeTrainPositionIndicator',
  props: {
    mergeTrainIndex: {
      type: Number,
      required: true,
    },
  },
  computed: {
    message() {
      return sprintf(s__('mrWidget|In the merge train at position %{mergeTrainPosition}'), {
        mergeTrainPosition: this.mergeTrainIndex + 1,
      });
    },
  },

  emits: [],
};
</script>

<template>
  <div class="pt-2 pb-2 pl-3 plr-3 merge-train-position-indicator">
    <div class="media-body">
      {{ message }}
    </div>
  </div>
</template>
