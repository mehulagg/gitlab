import { shallowMount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';
import ProjectPipelineStatus from 'ee/security_dashboard/components/project_pipeline_status.vue';
import PipelineStatusBadge from 'ee/security_dashboard/components/pipeline_status_badge.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

describe('Project Pipeline Status Component', () => {
  let wrapper;

  const propsData = {
    pipeline: {
      createdAt: '2020-10-06T20:08:07Z',
      id: '214',
      path: '/mixed-vulnerabilities/dependency-list-test-01/-/pipelines/214',
    },
  };

  const findPipelineStatusBadge = () => wrapper.find(PipelineStatusBadge);
  const findTimeAgoTooltip = () => wrapper.find(TimeAgoTooltip);
  const findLink = () => wrapper.find(GlLink);

  const createWrapper = options => {
    return shallowMount(ProjectPipelineStatus, {
      propsData,
      ...options,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default state', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('should show the timeAgoTooltip component', () => {
      const TimeComponent = findTimeAgoTooltip();
      expect(TimeComponent.exists()).toBeTruthy();
      expect(TimeComponent.props()).toStrictEqual({
        time: propsData.pipeline.createdAt,
        cssClass: '',
        tooltipPlacement: 'top',
      });
    });

    it('should show the link component', () => {
      const GlLinkComponent = findLink();
      expect(GlLinkComponent.exists()).toBeTruthy();
      expect(GlLinkComponent.text()).toBe(`#${propsData.pipeline.id}`);
      expect(GlLinkComponent.attributes('href')).toBe(propsData.pipeline.path);
    });
  });

  describe('when there are more than 0 failed jobs', () => {
    beforeEach(() => {
      wrapper = createWrapper({ provide: { pipelineSecurityBuildsFailedCount: 5 } });
    });

    it('should show the pipeline status badge', () => {
      expect(findPipelineStatusBadge().exists()).toBe(true);
    });
  });

  describe('when there are 0 failed jobs', () => {
    beforeEach(() => {
      wrapper = createWrapper({ provide: { pipelineSecurityBuildsFailedCount: 0 } });
    });

    it('should show the pipeline status badge', () => {
      expect(findPipelineStatusBadge().exists()).toBe(false);
    });
  });
});
