<script>
import { GlCard } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'TestCoverageTable',
  components: {
    GlCard,
  },
  text: {
    // This is a temporary placeholder until we actually implement the feature
    header: s__('RepositoriesAnalytics|Test Code Coverage'),
  },
};
</script>
<template>
  <gl-card>
    <template #header>
      <h5>{{ $options.text.header }}</h5>
    </template>
  </gl-card>
</template>
