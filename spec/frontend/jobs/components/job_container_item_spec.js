import { mount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';
import JobContainerItem from '~/jobs/components/job_container_item.vue';
import job from '../mock_data';

describe('JobContainerItem', () => {
  let wrapper;
  const delayedJobFixture = getJSONFixture('jobs/delayed.json');

  function mountShallowComponent(jobData = {}, props = { isActive: false, retried: false }) {
    wrapper = mount(JobContainerItem, {
      propsData: {
        job: {
          ...jobData,
          retried: props.retried,
        },
        isActive: props.isActive,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when a job is not active and not retried', () => {
    beforeEach(() => {
      mountShallowComponent(job);
    });

    it('displays a status icon', () => {
      expect(wrapper.vm.$el).toHaveSpriteIcon(job.status.icon);
    });

    it('displays the job name', () => {
      expect(wrapper.text()).toContain(job.name);
    });

    it('displays a link to the job', () => {
      const link = wrapper.findComponent(GlLink);

      expect(link.attributes('href')).toBe(job.status.details_path);
    });
  });

  describe('when a job is active', () => {
    beforeEach(() => {
      mountShallowComponent(job, { isActive: true });
    });

    it('displays an arrow sprite icon', () => {
      expect(wrapper.vm.$el).toHaveSpriteIcon('arrow-right');
    });
  });

  describe('when a job is retried', () => {
    beforeEach(() => {
      mountShallowComponent(job, { isActive: false, retried: true });
    });

    it('displays a retry icon', () => {
      expect(wrapper.vm.$el).toHaveSpriteIcon('retry');
    });
  });

  describe('for a delayed job', () => {
    beforeEach(() => {
      const remainingMilliseconds = 1337000;
      jest
        .spyOn(Date, 'now')
        .mockImplementation(
          () => new Date(delayedJobFixture.scheduled_at).getTime() - remainingMilliseconds,
        );

      mountShallowComponent(delayedJobFixture);
    });

    it('displays remaining time in tooltip', async () => {
      await wrapper.vm.$nextTick();

      const link = wrapper.findComponent(GlLink);

      expect(link.attributes('title')).toMatch('delayed job - delayed manual action (00:22:17)');
    });
  });
});
