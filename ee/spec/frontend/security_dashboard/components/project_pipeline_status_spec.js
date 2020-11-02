import { shallowMount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';
import ProjectPipelineStatus from 'ee/security_dashboard/components/project_pipeline_status.vue';
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

  const findLink = () => wrapper.find(GlLink);
  const findTimeAgoTooltip = () => wrapper.find(TimeAgoTooltip);

  const createWrapper = () => {
    return shallowMount(ProjectPipelineStatus, {
      propsData,
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
});
