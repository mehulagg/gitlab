import Vue from 'vue';
import { fetchCommitMergeRequests } from '~/commit_merge_requests';
import MiniPipelineGraph from '~/mini_pipeline_graph_dropdown';
import PipelineMiniGraph from '~/pipelines/components/pipelines_list/pipeline_mini_graph.vue';
import { initDetailsButton } from './init_details_button';
import { loadBranches } from './load_branches';

export const initCommitBoxInfo = (containerSelector = '.js-commit-box-info') => {
  const containerEl = document.querySelector(containerSelector);

  // Display commit related branches
  loadBranches(containerEl);

  // Related merge requests to this commit
  fetchCommitMergeRequests();

  // Display pipeline info for this commit
  new MiniPipelineGraph({
    container: '.js-commit-pipeline-graph',
  }).bindEvents();

  // POC:
  const el = document.querySelector('.js-commit-pipeline-graph-vue');
  // eslint-disable-next-line no-new
  new Vue({
    el,
    render(createElement) {
      return createElement(PipelineMiniGraph, {
        props: {
          stages: JSON.parse(el.dataset.stages),
        },
      });
    },
  });

  initDetailsButton();
};
