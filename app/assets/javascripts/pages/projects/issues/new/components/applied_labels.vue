<script>
import { GlLabel } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';

export default {
  components: {
    GlLabel,
  },
  props: {
    targetParent: {
      type: Element,
      required: true,
    },
    selectedLabels: {
      type: Array,
      required: false,
      default: () => [],
    },
    labelsPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      labels: [],
      appliedLabels: this.selectedLabels,
    };
  },
  destroy() {
    this.targetParent.removeEventListener('click');
  },
  mounted() {
    axios
      .get(this.labelsPath)
      .then(({ data }) => {
        this.labels = data;
      })
      .catch(e => {
        this.labels = [];
      });

    const ctx = this;
    this.targetParent.addEventListener('click', ({ target }) => {
      if (this.labels.length) {
        if (target.classList.contains('label-item')) {
          const { labelId } = target.dataset;
          ctx.handleLabelSelect(parseInt(labelId, 10));
        }
      }
    });
  },
  methods: {
    isScoped({ title = '' }) {
      return title.indexOf('::') > -1;
    },
    handleLabelSelect(labelId) {
      const byLabel = item => item.id === labelId;
      if (!this.appliedLabels.map(({ id }) => id).includes(byLabel)) {
        const newLabel = this.labels.find(byLabel);
        this.appliedLabels = [...this.appliedLabels, newLabel];
      } else {
        this.appliedLabels = this.appliedLabels.filter(l => l.id !== labelId);
      }
    },
  },
};
</script>
<template>
  <div v-if="appliedLabels.length" class="issuable-show-labels">
    <span>{{ 'Applied labels: ' }}</span>
    <template v-for="label in appliedLabels">
      <gl-label
        :key="label.id"
        :background-color="label.color"
        :title="label.title"
        :description="label.description"
        :scoped="isScoped(label)"
      />
    </template>
  </div>
</template>
