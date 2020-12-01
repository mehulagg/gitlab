<script>
import { GlSprintf } from '@gitlab/ui';

export default {
  components: { GlSprintf },
  props: {
    sprintfMessage: { type: String, required: true },
  },
  computed: {
    valueName() {
      // Get the name of the placeholder that's not %{labelStart} or %{labelEnd}.
      return this.sprintfMessage.match(/%{(?!(labelStart|labelEnd))(.+)}/)[2];
    },
  },
};
</script>

<template>
  <li :data-testid="valueName" class="gl-list-style-none gl-ml-0! gl-mb-4">
    <gl-sprintf :message="sprintfMessage">
      <template #label="{ content }">
        <strong data-testid="label">{{ content }}</strong>
      </template>
      <template #[valueName]>
        <span data-testid="value"><slot></slot></span>
      </template>
    </gl-sprintf>
  </li>
</template>
