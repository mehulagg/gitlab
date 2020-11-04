<script>
import { mapState, mapMutations } from 'vuex';
import { GlAlert } from '@gitlab/ui';
import MembersTable from '~/vue_shared/components/members/table/members_table.vue';
import { scrollToElement } from '~/lib/utils/common_utils';
import { HIDE_ERROR } from '~/vuex_shared/modules/members/mutation_types';

export default {
  name: 'GroupMembersApp',
  components: { MembersTable, GlAlert },
  props: {
    loadingEl: {
      type: HTMLDivElement,
      required: false,
      default: null,
    },
  },
  computed: {
    ...mapState(['showError', 'errorMessage']),
  },
  watch: {
    showError(value) {
      if (value) {
        this.$nextTick(() => {
          scrollToElement(this.$refs.errorAlert.$el);
        });
      }
    },
  },
  mounted() {
    if (!this.loadingEl) {
      return;
    }

    this.loadingEl.parentNode.removeChild(this.loadingEl);
  },
  methods: {
    ...mapMutations({
      hideError: HIDE_ERROR,
    }),
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="showError" ref="errorAlert" variant="danger" @dismiss="hideError">{{
      errorMessage
    }}</gl-alert>
    <members-table />
  </div>
</template>
