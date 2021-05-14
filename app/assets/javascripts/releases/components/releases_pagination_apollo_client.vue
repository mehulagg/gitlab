<script>
import { GlKeysetPagination } from '@gitlab/ui';
import { historyPushState, buildUrlWithCurrentLocation } from '~/lib/utils/common_utils';
import { isBoolean } from 'lodash';

export default {
  name: 'ReleasesPaginationApolloClient',
  components: { GlKeysetPagination },
  props: {
    pageInfo: {
      type: Object,
      required: true,
      validator: (info) => isBoolean(info.hasPreviousPage) && isBoolean(info.hasNextPage),
    },
    value: {
      type: Object,
      required: true,
    },
  },
  computed: {
    showPagination() {
      return this.pageInfo.hasPreviousPage || this.pageInfo.hasNextPage;
    },
  },
  methods: {
    onPrev(before) {
      historyPushState(buildUrlWithCurrentLocation(`?before=${before}`));
      this.$emit('input', {
        before,
        after: null,
      });
    },
    onNext(after) {
      historyPushState(buildUrlWithCurrentLocation(`?after=${after}`));
      this.$emit('input', {
        before: null,
        after,
      });
    },
  },
};
</script>
<template>
  <div class="gl-display-flex gl-justify-content-center">
    <gl-keyset-pagination
      v-if="showPagination"
      v-bind="pageInfo"
      @prev="onPrev($event)"
      @next="onNext($event)"
    />
  </div>
</template>
