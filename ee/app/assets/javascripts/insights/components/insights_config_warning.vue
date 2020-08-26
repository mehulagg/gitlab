<script>
import { imagePath } from '~/lib/utils/common_utils';

export default {
  props: {
    image: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    summary: {
      type: String,
      required: true,
    },
  },
  computed: {
    imageSrc() {
      return imagePath(this.image);
    },
  },

  emits: [],
};
</script>
<template>
  <div class="row js-empty-state empty-state">
    <div class="col-12">
      <div class="svg-content"><img class="content-image" :src="imageSrc" /></div>
    </div>
    <div class="col-12">
      <div class="text-content">
        <h4 class="content-title text-center">{{ title }}</h4>
        <p class="content-summary">{{ summary }}</p>
      </div>
    </div>
  </div>
</template>
