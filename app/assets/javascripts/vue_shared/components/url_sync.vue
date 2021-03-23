<script>
import { historyPushState } from '~/lib/utils/common_utils';
import { mergeUrlParams } from '~/lib/utils/url_utility';

export default {
  props: {
    query: {
      type: Object,
      required: false,
      default: null,
    },
  },
  watch: {
    query: {
      immediate: true,
      deep: true,
      handler(newQuery) {
        this.updateQuery(newQuery);
      },
    },
  },
  methods: {
    updateQuery(newQuery) {
      historyPushState(mergeUrlParams(newQuery, window.location.href, { spreadArrays: true }));
    },
  },
  render() {
    if (this.$scopedSlots.default) {
      return this.$scopedSlots.default({ updateQuery: this.updateQuery });
    }
    return this.$slots.default;
  },
};
</script>
