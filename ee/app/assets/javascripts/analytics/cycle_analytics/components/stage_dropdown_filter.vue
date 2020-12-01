<script>
import { GlDropdown, GlDropdownSectionHeader, GlDropdownItem } from '@gitlab/ui';
import { sprintf, s__ } from '~/locale';

export default {
  name: 'StageDropdownFilter',
  components: {
    GlDropdown,
    GlDropdownSectionHeader,
    GlDropdownItem,
  },
  props: {
    stages: {
      type: Array,
      required: true,
    },
    label: {
      type: String,
      required: false,
      default: s__('CycleAnalytics|stage dropdown'),
    },
  },
  data() {
    return {
      selectedStages: this.stages,
    };
  },
  computed: {
    selectedStagesLabel() {
      const { stages, selectedStages } = this;

      if (selectedStages.length === 1) {
        return selectedStages[0].title;
      } else if (selectedStages.length === stages.length) {
        return s__('CycleAnalytics|All stages');
      } else if (selectedStages.length > 1) {
        return sprintf(s__('CycleAnalytics|%{stageCount} stages selected'), {
          stageCount: selectedStages.length,
        });
      }

      return s__('CycleAnalytics|No stages selected');
    },
  },

  methods: {
    isStageSelected(stageId) {
      return this.selectedStages.some(({ id }) => id === stageId);
    },
    onClick({ stage, isMarking }) {
      this.selectedStages = isMarking
        ? this.selectedStages.filter(s => s.id !== stage.id)
        : this.selectedStages.concat([stage]);

      this.$emit('selected', this.selectedStages);
    },
  },
};
</script>

<template>
  <gl-dropdown
    ref="stagesDropdown"
    class="js-dropdown-stages"
    toggle-class="gl-shadow-none"
    :text="selectedStagesLabel"
    right
  >
    <gl-dropdown-section-header>{{ s__('CycleAnalytics|Stages') }}</gl-dropdown-section-header>
    <gl-dropdown-item
      v-for="stage in stages"
      :key="stage.id"
      :active="isStageSelected(stage.id)"
      :is-check-item="true"
      :is-checked="isStageSelected(stage.id)"
      @click="onClick({ stage, isMarking: isStageSelected(stage.id) })"
    >
      {{ stage.title }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
