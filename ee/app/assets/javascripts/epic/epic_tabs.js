import $ from 'jquery';
import initRelatedItemsTree from 'ee/related_items_tree/related_items_tree_bundle';
import { parseBoolean } from '~/lib/utils/common_utils';

export default class EpicTabs {
  constructor() {
    this.epicTreesEnabled = gon.features && gon.features.epicTrees;
    this.wrapper = document.querySelector('.js-epic-container:not(.breadcrumbs)');
    this.epicTabs = this.wrapper.querySelector('.js-epic-tabs-container');
    this.discussionFilterContainer = this.epicTabs.querySelector('.js-discussion-filter-container');
    const allowSubEpics = parseBoolean(this.epicTabs.dataset.allowSubEpics);

    initRelatedItemsTree();

    // We need to execute Roadmap tab related
    // logic only when sub-epics feature is available.
    if (allowSubEpics) {
      this.roadmapTabLoaded = false;

      this.loadRoadmapBundle();
      this.bindEvents();
    }
  }

  /**
   * This method loads Roadmap app bundle asynchronously.
   *
   * @param {boolean} allowSubEpics
   */
  loadRoadmapBundle() {
    import('ee/roadmap/roadmap_bundle')
      .then(roadmapBundle => {
        this.initRoadmap = roadmapBundle.default;
      })
      .catch(() => {});
  }

  bindEvents() {
    const $roadmapTab = $('#roadmap-tab', this.epicTabs);

    $roadmapTab.on('show.bs.tab', this.onRoadmapShow.bind(this));
    $roadmapTab.on('hide.bs.tab', this.onRoadmapHide.bind(this));
  }

  onRoadmapShow() {
    this.wrapper.classList.remove('container-limited');
    if (!this.roadmapTabLoaded) {
      this.initRoadmap();
      this.roadmapTabLoaded = true;
    }
  }

  onRoadmapHide() {
    this.wrapper.classList.add('container-limited');
  }
}
