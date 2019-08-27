<script>
import { sprintf, s__, n__ } from '~/locale';
import $ from 'jquery';
import _ from 'lodash-es';
import Icon from '~/vue_shared/components/icon.vue';
import { GlButton } from '@gitlab/ui';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';

export default {
  name: 'StageDropdownFilter',
  components: {
    Icon,
    GlButton,
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
      selectedStages: [],
    };
  },
  computed: {
    selectedStagesLabel() {
      return this.selectedStages.length
        ? sprintf(
            n__(
              'CycleAnalytics|%{stageName}',
              'CycleAnalytics|%d stages selected',
              this.selectedStages.length,
            ),
            { stageName: capitalizeFirstCharacter(this.selectedStages[0].name) },
          )
        : s__('CycleAnalytics|All stages');
    },
  },
  mounted() {
    $(this.$refs.stagesDropdown).glDropdown({
      selectable: true,
      multiSelect: true,
      clicked: this.onClick.bind(this),
      data: this.formatData.bind(this),
      renderRow: group => this.rowTemplate(group),
      text: stage => stage.name,
    });
  },
  methods: {
    setSelectedStages(selectedObj, isMarking) {
      this.selectedStages = isMarking
        ? this.selectedStages.concat([selectedObj])
        : this.selectedStages.filter(stage => stage.name !== selectedObj.name);
    },
    onClick({ selectedObj, e, isMarking }) {
      e.preventDefault();
      this.setSelectedStages(selectedObj, isMarking);
      this.$emit('selected', this.selectedStages);
    },
    formatData(term, callback) {
      callback(this.stages);
    },
    rowTemplate(stage) {
      return `
          <li>
            <a href='#' class='dropdown-menu-link'>
              ${_.escape(capitalizeFirstCharacter(stage.name))}
            </a>
          </li>
        `;
    },
  },
};
</script>

<template>
  <div>
    <div ref="stagesDropdown" class="dropdown dropdown-stages">
      <gl-button
        class="dropdown-menu-toggle wide shadow-none bg-white"
        type="button"
        data-toggle="dropdown"
        aria-expanded="false"
        :aria-label="label"
      >
        {{ selectedStagesLabel }}
        <icon name="chevron-down" />
      </gl-button>
      <div class="dropdown-menu dropdown-menu-selectable dropdown-menu-full-width">
        <div class="dropdown-title text-left">{{ s__('CycleAnalytics|Stages') }}</div>
        <div class="dropdown-content"></div>
      </div>
    </div>
  </div>
</template>
