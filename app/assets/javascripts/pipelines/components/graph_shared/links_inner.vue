<script>
import { isEmpty } from 'lodash';
import { performanceMarkAndMeasure } from '~/performance/utils';
import {
  PIPELINE_LINKS_MARK_CALCULATE_START,
  PIPELINE_LINKS_MARK_CALCULATE_END,
  PIPELINE_LINKS_MEASURE_CALCULATION,
} from '~/performance/constants.js'
import { DRAW_FAILURE } from '../../constants';
import { createJobsHash, generateJobNeedsDict } from '../../utils';
import { parseData } from '../parsing_utils';
import { generateLinksData } from './drawing_utils';

export default {
  name: 'LinksInner',
  STROKE_WIDTH: 2,
  props: {
    containerId: {
      type: String,
      required: true,
    },
    containerMeasurements: {
      type: Object,
      required: true,
    },
    pipelineId: {
      type: Number,
      required: true,
    },
    pipelineData: {
      type: Array,
      required: true,
    },
    totalGroups: {
      type: Number,
      required: true,
    },
    metricsConfig: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    defaultLinkColor: {
      type: String,
      required: false,
      default: 'gl-stroke-gray-200',
    },
    highlightedJob: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      links: [],
      needsObject: null,
    };
  },
  computed: {
    hasHighlightedJob() {
      return Boolean(this.highlightedJob);
    },
    isPipelineDataEmpty() {
      return isEmpty(this.pipelineData);
    },
    highlightedJobs() {
      // If you are hovering on a job, then the jobs we want to highlight are:
      // The job you are currently hovering + all of its needs.
      return this.hasHighlightedJob
        ? [this.highlightedJob, ...this.needsObject[this.highlightedJob]]
        : [];
    },
    highlightedLinks() {
      // If you are hovering on a job, then the links we want to highlight are:
      // All the links whose `source` and `target` are highlighted jobs.
      if (this.hasHighlightedJob) {
        const filteredLinks = this.links.filter((link) => {
          return (
            this.highlightedJobs.includes(link.source) && this.highlightedJobs.includes(link.target)
          );
        });

        return filteredLinks.map((link) => link.ref);
      }

      return [];
    },
    viewBox() {
      return [0, 0, this.containerMeasurements.width, this.containerMeasurements.height];
    },
  },
  watch: {
    highlightedJob() {
      // On first hover, generate the needs reference
      if (!this.needsObject) {
        const jobs = createJobsHash(this.pipelineData);
        this.needsObject = generateJobNeedsDict(jobs) ?? {};
      }
    },
    highlightedJobs(jobs) {
      this.$emit('highlightedJobsChange', jobs);
    },
  },
  mounted() {
    if (!isEmpty(this.pipelineData)) {
      this.prepareLinkData();
    }
  },
  methods: {
    beginPerfMeasure(){
      if (this.metricsConfig.collectMetrics) {
        performanceMarkAndMeasure({ mark: PIPELINE_LINKS_MARK_CALCULATE_START })
      }
    },
    finishPerfMeasureAndSend(){
      if (this.metricsConfig.collectMetrics) {
        console.log('in if');
        performanceMarkAndMeasure({
          mark: PIPELINE_LINKS_MARK_CALCULATE_END,
          measures: [
            {
              name: PIPELINE_LINKS_MEASURE_CALCULATION,
              start: PIPELINE_LINKS_MARK_CALCULATE_START,
              end: PIPELINE_LINKS_MARK_CALCULATE_END,
            },
          ],
        })
      }

      console.log(window.performance.getEntriesByName(PIPELINE_LINKS_MEASURE_CALCULATION));

      const duration = window.performance.getEntriesByName(PIPELINE_LINKS_MEASURE_CALCULATION)[0]?.duration;
      const data = {
        histograms: [
          { name: 'pipeline_graph_link_calculation_duration_seconds', value: duration },
          { name: 'pipeline_graph_links_total', value: this.links.length },
          { name: 'pipeline_graph_link_per_job_ratio', value: this.links.length / this.totalGroups }
        ]
      };

      console.log('data', data);
      // get numbers
      // structure data
      // send data
    },
    isLinkHighlighted(linkRef) {
      return this.highlightedLinks.includes(linkRef);
    },
    prepareLinkData() {
      try {
        this.beginPerfMeasure();
        const arrayOfJobs = this.pipelineData.flatMap(({ groups }) => groups);
        const parsedData = parseData(arrayOfJobs);
        this.links = generateLinksData(parsedData, this.containerId, `-${this.pipelineId}`);
        this.finishPerfMeasureAndSend();
      } catch (err) {
        console.log(err);
        this.$emit('error', DRAW_FAILURE);
      }
    },
    getLinkClasses(link) {
      return [
        this.isLinkHighlighted(link.ref) ? 'gl-stroke-blue-400' : this.defaultLinkColor,
        { 'gl-opacity-3': this.hasHighlightedJob && !this.isLinkHighlighted(link.ref) },
      ];
    },
  },
};
</script>
<template>
  <div class="gl-display-flex gl-relative">
    <svg
      id="link-svg"
      class="gl-absolute gl-pointer-events-none"
      :viewBox="viewBox"
      :width="`${containerMeasurements.width}px`"
      :height="`${containerMeasurements.height}px`"
    >
      <path
        v-for="link in links"
        :key="link.path"
        :ref="link.ref"
        :d="link.path"
        class="gl-fill-transparent gl-transition-duration-slow gl-transition-timing-function-ease"
        :class="getLinkClasses(link)"
        :stroke-width="$options.STROKE_WIDTH"
      />
    </svg>
    <slot></slot>
  </div>
</template>
