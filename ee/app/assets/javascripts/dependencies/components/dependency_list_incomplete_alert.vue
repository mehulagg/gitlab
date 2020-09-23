<script>
import { GlAlert } from '@gitlab/ui';

export default {
  name: 'DependencyListIncompleteAlert',
  components: {
    GlAlert,
  },
  data() {
    return {
      dependencyFiles: [
        'package-lock.json',
        'composer.lock',
        'Gemfile.lock',
        'gems.locked',
        'yarn.lock',
        'requirements.txt',
        'pom.xml',
      ],
    };
  },
};
</script>

<template>
  <gl-alert
    variant="warning"
    :title="s__('Dependencies|Unsupported file(s) detected')"
    v-on="$listeners"
  >
    <p>
      {{
        __(
          'One or more of your dependency files are not supported, and the dependency list may be incomplete. Below is a list of supported file types.',
        )
      }}
    </p>
    <ul class="mb-0">
      <li v-for="file in dependencyFiles" :key="file">{{ file }}</li>
    </ul>
  </gl-alert>
</template>
