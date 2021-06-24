<script>
import { s__, n__, sprintf } from '~/locale';

export default {
  props: {
    stageCount: {
      type: Number,
      default: null,
    },
  },
  computed: {
    formattedStageCount() {
      if (this.stageCount === null) {
        return '-';
      } else if (this.stageCount === 1001) {
        return sprintf(s__('%ValueStreamAnalytics|%{stageCount} items'), { stageCount: '1000+' });
      } else {
        return n__('%d item', '%d items', this.stageCount);
      }
    },
  },
  render() {
    return this.$scopedSlots.default({
      formattedStageCount: this.formattedStageCount,
    });
  },
};
</script>
