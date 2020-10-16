<script>
import { isEmpty } from 'lodash';
import { generateLinksData } from './drawing_utils';
import { parseData } from '../parsing_utils';
import { generateJobNeedsDict } from '../../utils';

import { DRAW_FAILURE } from '../../constants';

export default {
  STROKE_WIDTH: 2,
  props: {
    pipelineData: {
      type: Object,
      required: true,
    },
    highlightedJob: {
      type: String,
      required: false,
      default: '',
    },
    containerId: {
      type: String,
      required: true,
    },
    containerRef: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      links: [],
      needsObject: null,
      height: 0,
      width: 0,
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
        const filteredLinks = this.links.filter(link => {
          return (
            this.highlightedJobs.includes(link.source) && this.highlightedJobs.includes(link.target)
          );
        });

        return filteredLinks.map(link => link.ref);
      }

      return [];
    },
    viewBox() {
      return [0, 0, this.width, this.height];
    },
  },
  watch: {
    highlightedJob() {
      if (!this.needsObject) {
        this.needsObject = generateJobNeedsDict(this.pipelineData) ?? {};
      }

      this.$emit('on-highlighted-jobs-change', this.highlightedJobs);
    },
  },
  mounted() {
    if (!this.isPipelineDataEmpty) {
      this.getGraphDimensions();
      this.drawJobLinks();
    }
  },
  methods: {
    getGraphDimensions() {
      this.width = `${this.$parent.$refs[this.containerRef].scrollWidth}px`;
      this.height = `${this.$parent.$refs[this.containerRef].scrollHeight}px`;
    },
    drawJobLinks() {
      const { stages, jobs } = this.pipelineData;
      const unwrappedGroups = this.unwrapPipelineData(stages);

      try {
        const parsedData = parseData(unwrappedGroups);
        this.links = generateLinksData(parsedData, jobs, this.containerId);
      } catch {
        this.$emit('error', DRAW_FAILURE);
      }
    },
    highlightNeeds(uniqueJobId) {
      // The first time we hover, we create the object where
      // we store all the data to properly highlight the needs.
      if (!this.needsObject) {
        this.needsObject = generateJobNeedsDict(this.pipelineData) ?? {};
      }

      this.highlightedJob = uniqueJobId;
    },
    unwrapPipelineData(stages) {
      return stages
        .map(({ name, groups }) => {
          return groups.map(group => {
            return { category: name, ...group };
          });
        })
        .flat(2);
    },
    isLinkHighlighted(linkRef) {
      return this.highlightedLinks.includes(linkRef);
    },
    getLinkClasses(link) {
      return [
        this.isLinkHighlighted(link.ref) ? 'gl-stroke-blue-400' : 'gl-stroke-gray-200',
        { 'gl-opacity-3': this.hasHighlightedJob && !this.isLinkHighlighted(link.ref) },
      ];
    },
  },
};
</script>
<template>
  <div class="gl-display-flex">
    <svg :viewBox="viewBox" :width="width" :height="height" class="gl-absolute">
      <template>
        <path
          v-for="link in links"
          :key="link.path"
          :ref="link.ref"
          :d="link.path"
          class="gl-fill-transparent gl-transition-duration-slow gl-transition-timing-function-ease"
          :class="getLinkClasses(link)"
          :stroke-width="$options.STROKE_WIDTH"
        />
      </template>
    </svg>
    <slot></slot>
  </div>
</template>
