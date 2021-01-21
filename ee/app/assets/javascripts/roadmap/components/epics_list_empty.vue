<script>
/* eslint-disable vue/no-v-html */
import { GlButton } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { dateInWords } from '~/lib/utils/datetime_utility';

import CommonMixin from '../mixins/common_mixin';
import { emptyStateDefault, emptyStateWithFilters } from '../constants';

import initEpicCreate from '../../epic/epic_bundle';

export default {
  components: {
    GlButton,
  },
  mixins: [CommonMixin],
  props: {
    presetType: {
      type: String,
      required: true,
    },
    timeframeStart: {
      type: [Date, Object],
      required: true,
    },
    timeframeEnd: {
      type: [Date, Object],
      required: true,
    },
    hasFiltersApplied: {
      type: Boolean,
      required: true,
    },
    newEpicEndpoint: {
      type: String,
      required: true,
    },
    emptyStateIllustrationPath: {
      type: String,
      required: true,
    },
    isChildEpics: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    timeframeRange() {
      let startDate;
      let endDate;

      if (this.presetTypeQuarters) {
        const quarterStart = this.timeframeStart.range[0];
        const quarterEnd = this.timeframeEnd.range[2];
        startDate = dateInWords(
          quarterStart,
          true,
          quarterStart.getFullYear() === quarterEnd.getFullYear(),
        );
        endDate = dateInWords(quarterEnd, true);
      } else if (this.presetTypeMonths) {
        startDate = dateInWords(
          this.timeframeStart,
          true,
          this.timeframeStart.getFullYear() === this.timeframeEnd.getFullYear(),
        );
        endDate = dateInWords(this.timeframeEnd, true);
      } else if (this.presetTypeWeeks) {
        const end = new Date(this.timeframeEnd.getTime());
        end.setDate(end.getDate() + 6);

        startDate = dateInWords(
          this.timeframeStart,
          true,
          this.timeframeStart.getFullYear() === end.getFullYear(),
        );
        endDate = dateInWords(end, true);
      }

      return {
        startDate,
        endDate,
      };
    },
    message() {
      if (this.hasFiltersApplied) {
        return s__('GroupRoadmap|Sorry, no epics matched your search');
      }
      return s__('GroupRoadmap|The roadmap shows the progress of your epics along a timeline');
    },
    subMessage() {
      if (this.isChildEpics) {
        return sprintf(
          s__(
            'GroupRoadmap|To view the roadmap, add a start or due date to one of the %{linkStart}child epics%{linkEnd}.',
          ),
          {
            linkStart:
              '<a href="https://docs.gitlab.com/ee/user/group/epics/#multi-level-child-epics" target="_blank" rel="noopener noreferrer nofollow">',
            linkEnd: '</a>',
          },
          false,
        );
      }

      if (this.hasFiltersApplied) {
        return sprintf(emptyStateWithFilters, {
          startDate: this.timeframeRange.startDate,
          endDate: this.timeframeRange.endDate,
        });
      }
      return sprintf(emptyStateDefault, {
        startDate: this.timeframeRange.startDate,
        endDate: this.timeframeRange.endDate,
      });
    },
  },
  mounted() {
    // If filters are not applied and yet user
    // is seeing empty state, we need to show
    // `New epic` button, so boot-up Epic app
    // in create mode.
    if (!this.hasFiltersApplied) {
      initEpicCreate(true);
    }
  },
};
</script>

<template>
  <div class="row empty-state">
    <div class="col-12">
      <div class="svg-content"><img :src="emptyStateIllustrationPath" /></div>
    </div>
    <div class="col-12">
      <div class="text-content">
        <h4>{{ message }}</h4>
        <p v-html="subMessage"></p>
        <div class="text-center">
          <div
            v-if="!hasFiltersApplied"
            id="epic-create-root"
            :data-endpoint="newEpicEndpoint"
          ></div>
          <gl-button :title="__('List')" :href="newEpicEndpoint">{{
            s__('View epics list')
          }}</gl-button>
        </div>
      </div>
    </div>
  </div>
</template>
