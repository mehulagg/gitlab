<script>
// We are using gl-breadcrumb only at the last child of the handwritten breadcrumb
// until this gitlab-ui issue is resolved: https://gitlab.com/gitlab-org/gitlab-ui/-/issues/1079
//
// See the CSS workaround in app/assets/stylesheets/pages/registry.scss when this file is changed.
import { GlBreadcrumb, GlIcon } from '@gitlab/ui';

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
      const pathArray = this.$route.path.split('/');
      const breadcrumbs = [];

      pathArray.forEach((path, index) => {
        const text =
          (this.$route.matched[index] && this.$route.matched[index].meta.breadcrumb) ?? path;
        if (text) {
          const prevPath = breadcrumbs[index - 1]?.path;
          const to = prevPath ? `/${prevPath}/${path}` : `/${path}`;

          breadcrumbs.push({
            path,
            to,
            text,
          });
        }
      }, []);

      return breadcrumbs;
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
