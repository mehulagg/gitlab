<script>
import { GlBreadcrumb, GlIcon, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';

export default {
  directives: { SafeHtml },
  components: {
    GlBreadcrumb,
    GlIcon,
  },
  props: {
    crumbs: {
      type: Array,
      required: true,
    },
  },
  computed: {
    rootRoute() {
      return this.$router.options.routes.find(r => r.meta.root);
    },
    isRootRoute() {
      return this.$route.name === this.rootRoute.name;
    },
    allCrumbs() {
      const crumbs = this.crumbs.map(c => {
        return { text: c.innerText, href: c.firstChild.href };
      });
      if (!this.isRootRoute) {
        const crumb = crumbs.pop();
        crumbs.push(
          {
            text: this.rootRoute.meta.nameGenerator(this.$store.state),
            href: this.$router.options.base,
          },
          crumb,
        );
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
