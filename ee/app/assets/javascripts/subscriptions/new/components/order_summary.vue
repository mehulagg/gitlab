<script>
import { mapGetters } from 'vuex';
import { GlIcon } from '@gitlab/ui';
import { sprintf, s__ } from '~/locale';
import formattingMixins from '../formatting_mixins';
import SummaryDetails from './order_summary/summary_details.vue';

export default {
  components: {
    SummaryDetails,
    GlIcon,
  },
  mixins: [formattingMixins],
  data() {
    return {
      collapsed: true,
    };
  },
  computed: {
    ...mapGetters(['totalAmount', 'name', 'usersPresent']),
    titleWithName() {
      return sprintf(this.$options.i18n.title, { name: this.name });
    },
  },
  methods: {
    toggleCollapse() {
      this.collapsed = !this.collapsed;
    },
  },
  i18n: {
    title: s__("Checkout|%{name}'s GitLab subscription"),
  },
};
</script>
<template>
  <div class="order-summary d-flex flex-column flex-grow-1 gl-mt-2 mt-lg-5">
    <div class="d-lg-none">
      <div @click="toggleCollapse">
        <h4 class="d-flex justify-content-between gl-font-lg" :class="{ 'gl-mb-7': !collapsed }">
          <div class="d-flex">
            <gl-icon v-if="collapsed" name="chevron-right" :size="18" />
            <gl-icon v-else name="chevron-down" :size="18" />
            <div>{{ titleWithName }}</div>
          </div>
          <div class="gl-ml-3">{{ formatAmount(totalAmount, usersPresent) }}</div>
        </h4>
      </div>
      <summary-details v-show="!collapsed" />
    </div>
    <div class="d-none d-lg-block">
      <div class="append-bottom-20">
        <h4>
          {{ titleWithName }}
        </h4>
      </div>
      <summary-details />
    </div>
  </div>
</template>
