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
      const messageBeginningTrainPosition = s__(
        'mrWidget|A new merge train has started and this merge request is the first of the queue.',
      );
      const messageAddedTrainPosition = sprintf(
        s__(
          'mrWidget|Added to the merge train. There are %{mergeTrainPosition} merge requests waiting to be merged',
        ),
        {
          mergeTrainPosition: this.mergeTrainIndex + 1,
        },
      );

      return this.mergeTrainIndex === 0 ? messageBeginningTrainPosition : messageAddedTrainPosition;
    },
  },
};
</script>

<template>
  <div class="pt-2 pb-2 pl-3 plr-3 merge-train-position-indicator">
    <div class="media-body">
      {{ message }}
    </div>
  </div>
</template>
