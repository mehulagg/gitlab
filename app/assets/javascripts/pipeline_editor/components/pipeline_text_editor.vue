<script>
import EditorLite from '~/vue_shared/components/editor_lite.vue';

export default {
  components: {
    EditorLite,
  },
  props: {
    value: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <div class="file-holder gl-mb-3">
    <editor-lite v-model="value" file-name="*.yml" :editor-options="{ readOnly: true }" />
  </div>
</template>
