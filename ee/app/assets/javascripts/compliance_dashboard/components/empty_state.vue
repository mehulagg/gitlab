<script>
import { __ } from '~/locale';

export default {
  props: {
    imagePath: {
      type: String,
      required: true,
    },
  },
  strings: {
    heading: __(
      "Merge requests are a place to propose changes you've made to a project and discuss those changes with others",
    ),
    subheading: __('Interested parties can even contribute by pushing commits if they want to.'),
    alt: __('Merge Requests'),
  },
};
</script>

<template>
  <div class="row empty-state merge-requests">
    <div class="col-12">
      <div class="svg-content">
        <img :src="imagePath" :alt="$options.strings.alt" />
      </div>
    </div>
    <div class="col-12">
      <div class="text-content">
        <h4>{{ $options.strings.heading }}</h4>
        <p>{{ $options.strings.subheading }}</p>
      </div>
    </div>
  </div>
</template>
