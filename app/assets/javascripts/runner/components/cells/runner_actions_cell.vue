<script>
import { GlButtonGroup, GlButton } from '@gitlab/ui';
import updateRunnerMutation from '../../graphql/update_runner.mutation.graphql';

export default {
  components: {
    GlButtonGroup,
    GlButton,
  },
  props: {
    runner: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      active: this.runner.active,
    };
  },
  computed: {
    isActive() {
      return this.runner.active;
    },
  },
  methods: {
    async onUpdateActive(active) {
      const { data } = await this.$apollo.mutate({
        mutation: updateRunnerMutation,
        variables: {
          input: {
            id: this.runner.id,
            active,
          },
        },
      });

      // TODO Update the apollo cache on success
      // TODO Handle errors
      // TODO Add a loading state
      console.log(data.updateRunner.runner);
    },
  },
};
</script>

<template>
  <gl-button-group>
    <!-- TODO add edit action -->
    <gl-button v-if="isActive" icon="pause" @click="onUpdateActive(false)" />
    <gl-button v-else icon="play" @click="onUpdateActive(true)" />
    <!-- TODO add delete action to update runners -->
  </gl-button-group>
</template>
