<script>
import { GlLink } from '@gitlab/ui';
import { isRootRelative } from '~/lib/utils/url_utility';

export default {
  components: {
    GlLink,
  },
  inject: ['projectFullPath'],
  props: {
    value: {
      type: String,
      required: true,
    },
  },
  computed: {
    commitPath() {
      const { projectFullPath, value } = this;
      // `projectFullPath` comes in two flavors: relative (e.g.: `group/project`) and  absolute (e.g.: `/group/project`)
      // adding a leading slash to the relative path makes sure we always link to an absolute path
      const absoluteProjectPath = isRootRelative(projectFullPath)
        ? projectFullPath
        : `/${projectFullPath}`;

      return `${absoluteProjectPath}/-/commit/${value}`;
    },
  },
};
</script>

<template>
  <gl-link :href="commitPath">{{ value }}</gl-link>
</template>
