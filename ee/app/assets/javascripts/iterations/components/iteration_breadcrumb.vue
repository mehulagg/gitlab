<script>
// We are using gl-breadcrumb only at the last child of the handwritten breadcrumb
// until this gitlab-ui issue is resolved: https://gitlab.com/gitlab-org/gitlab-ui/-/issues/1079
import { GlBreadcrumb, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlBreadcrumb,
    GlIcon,
  },
  computed: {
    allCrumbs() {
      const pathArray = this.$route.path.split('/');
      const breadcrumbs = [];

      pathArray.forEach((path, index) => {
        const text = this.$route.matched[index].meta?.breadcrumb || path;
        if (text) {
          const prevPath = breadcrumbs[index - 1]?.to || '';
          const to = `${prevPath}/${path}`.replace(/\/+/, '/');

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
  <gl-breadcrumb :items="allCrumbs" class="gl-p-0 gl-shadow-none">
    <template #separator>
      <gl-icon name="angle-right" :size="8" />
    </template>
  </gl-breadcrumb>
</template>
