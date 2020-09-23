<script>
import { GlLink } from '@gitlab/ui';
import { noneEpic } from 'ee/vue_shared/constants';

export default {
  noneEpic,
  components: {
    GlLink,
  },
  props: {
    epics: {
      type: Array,
      required: true,
    },
    selectedEpic: {
      type: Object,
      required: false,
      default: () => null,
    },
  },
  computed: {
    isNoEpic() {
      return (
        this.selectedEpic.id === this.$options.noneEpic.id &&
        this.selectedEpic.title === this.$options.noneEpic.title
      );
    },
  },
  methods: {
    isSelected(epic) {
      return this.selectedEpic.id === epic.id;
    },
    handleItemClick(epic) {
      if (epic.id !== this.selectedEpic.id) {
        this.$emit('onItemSelect', epic);
      } else if (epic.id !== noneEpic.id) {
        this.$emit('onItemSelect', noneEpic);
      }
    },
  },
};
</script>

<template>
  <div class="dropdown-content">
    <ul>
      <li data-epic-id="None">
        <gl-link
          :class="{ 'is-active': isNoEpic }"
          @click.prevent="handleItemClick($options.noneEpic)"
          >{{ __('No Epic') }}</gl-link
        >
      </li>
      <li class="divider"></li>
      <template v-if="epics.length">
        <li v-for="epic in epics" :key="epic.id">
          <gl-link
            :class="{ 'is-active': isSelected(epic) }"
            @click.prevent="handleItemClick(epic)"
            >{{ epic.title }}</gl-link
          >
        </li>
      </template>
      <li v-else class="d-block text-center p-2">{{ __('No matches found') }}</li>
    </ul>
  </div>
</template>
