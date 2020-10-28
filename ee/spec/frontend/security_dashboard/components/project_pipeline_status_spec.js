import { shallowMount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';
import ProjectPipelineStatus from 'ee/security_dashboard/components/project_pipeline_status.vue';
import PipelineStatusBadge from 'ee/security_dashboard/components/pipeline_status_badge.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

describe('Project Pipeline Status Component', () => {
  let wrapper;

  const DEFAULT_PROPS = {
    pipeline: {
      createdAt: '2020-10-06T20:08:07Z',
      id: '214',
      path: '/mixed-vulnerabilities/dependency-list-test-01/-/pipelines/214',
    },
  };

  const findPipelineStatusBadge = () => wrapper.find(PipelineStatusBadge);
  const findTimeAgoTooltip = () => wrapper.find(TimeAgoTooltip);
  const findLink = () => wrapper.find(GlLink);

  const createWrapper = ({ props = {}, options = {} } = {}) => {
    return shallowMount(ProjectPipelineStatus, {
      propsData: { ...DEFAULT_PROPS, ...props },
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
        time: DEFAULT_PROPS.pipeline.createdAt,
        cssClass: '',
        tooltipPlacement: 'top',
      });
    });

    it('should show the link component', () => {
      const GlLinkComponent = findLink();
      expect(GlLinkComponent.exists()).toBeTruthy();
      expect(GlLinkComponent.text()).toBe(`#${DEFAULT_PROPS.pipeline.id}`);
      expect(GlLinkComponent.attributes('href')).toBe(DEFAULT_PROPS.pipeline.path);
    });
  });

  describe('when no pipeline has run', () => {
    beforeEach(() => {
      wrapper = createWrapper({ props: { pipeline: { path: '' } } });
    });

    it('should not show the project_pipeline_status component', () => {
      expect(findLink().exists()).toBe(false);
      expect(findTimeAgoTooltip().exists()).toBe(false);
      expect(findPipelineStatusBadge().exists()).toBe(false);
    });
  });
});
