<script>
// We are using gl-breadcrumb only at the last child of the handwritten breadcrumb
// until this gitlab-ui issue is resolved: https://gitlab.com/gitlab-org/gitlab-ui/-/issues/1079
//
// See the CSS workaround in app/assets/stylesheets/pages/registry.scss when this file is changed.
import { GlBreadcrumb, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlBreadcrumb,
    GlIcon,
  },
  computed: {
    rootRoute() {
      return this.$router.options.routes.find((r) => r.path === '/');
    },
    cadenceId() {
      return this.$route.params.cadenceId;
    },
    iterationId() {
      return this.$route.params.iterationId;
    },
    isRootRoute() {
      return this.$route.name === this.rootRoute.name;
    },
    allCrumbs() {
      const crumbs = [
        {
          text: this.rootRoute.meta.breadCrumb,
          to: this.rootRoute.path,
        },
      ];
      if (this.cadenceId) {
        crumbs.push({
          text: this.cadenceId,
        });
      }
      if (this.iterationId) {
        crumbs.push({
          text: this.iterationId,
        });
      }
      if (this.$route.path.endsWith('new')) {
        crumbs.push({
          text: this.$route.meta.breadCrumb,
        });
      }
      if (this.$route.path.endsWith('edit')) {
        crumbs.push({
          text: __('Edit'),
        });
      }
      return crumbs;
    },
  },
};
</script>

<template>
  <gl-breadcrumb :items="allCrumbs">
    <template #separator>
      <gl-icon name="angle-right" :size="8" />
    </template>
  </gl-breadcrumb>
</template>
