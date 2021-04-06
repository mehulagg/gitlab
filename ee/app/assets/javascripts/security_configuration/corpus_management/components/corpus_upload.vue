<script>
import { GlButton, GlSprintf } from '@gitlab/ui';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import { s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlSprintf,
  },
  props: {
    totalSize: {
      type: Number,
      required: true,
    },
  },
  i18n: {
    totalSize: s__('CorpusManagement|Total Size: %{totalSize}'),
    newCorpus: s__('CorpusManagement|New corpus'),
  },
  computed: {
    formattedFileSize() {
      return numberToHumanSize(this.totalSize);
    },
  },
  methods: {
    newCorpus() {
      this.$emit('newcorpus');
    },
  },
};
</script>
<template>
  <div
    class="gl-h-11 gl-bg-gray-10 gl-display-flex gl-justify-content-space-between gl-align-items-center"
  >
    <div class="gl-ml-5">
      <gl-sprintf :message="$options.i18n.totalSize">
        <template #totalSize>
          <span class="gl-font-weight-bold">{{ formattedFileSize }}</span>
        </template>
      </gl-sprintf>
    </div>

    <gl-button class="gl-mr-5" category="primary" variant="confirm" @click="newCorpus">
      {{ this.$options.i18n.newCorpus }}
    </gl-button>
  </div>
</template>
