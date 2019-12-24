import { shallowMount, mount, createLocalVue } from '@vue/test-utils';
import VisualReviewAppLink from 'ee/vue_merge_request_widget/components/visual_review_app_link.vue';
import { GlButton, GlModal } from '@gitlab/ui';
import { mockTracking, triggerEvent } from 'helpers/tracking_helper';
import ModalCopyButton from '~/vue_shared/components/modal_copy_button.vue';

const localVue = createLocalVue();

describe('Visual Review App Link', () => {
  const Component = localVue.extend(VisualReviewAppLink);
  let wrapper;
  let propsData;

  beforeEach(() => {
    propsData = {
      cssClass: 'button cool-button best-button',
      appMetadata: {
        mergeRequestId: 1,
        sourceProjectId: 20,
        appUrl: 'http://gitlab.example.com',
        sourceProjectPath: 'source/project',
      },
      link: 'http://example.com',
    };
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('renders link and text', () => {
    beforeEach(() => {
      wrapper = mount(Component, {
        propsData,
        localVue,
      });
    });

    it('renders Review text', () => {
      expect(wrapper.find(GlButton).text()).toBe('Review');
    });

    it('renders provided cssClass as class attribute', () => {
      expect(wrapper.find(GlButton).attributes('class')).toEqual(
        expect.stringContaining(propsData.cssClass),
      );
    });
  });

  describe('renders the modal', () => {
    beforeEach(() => {
      wrapper = shallowMount(Component, {
        sync: false,
        propsData,
        localVue,
      });
    });
    it('with expected project Id', () => {
      expect(wrapper.find(GlModal).text()).toEqual(
        expect.stringContaining(`data-project-id='${propsData.appMetadata.sourceProjectId}'`),
      );
    });

    it('with expected project path', () => {
      expect(wrapper.find(GlModal).text()).toEqual(
        expect.stringContaining(`data-project-path='${propsData.appMetadata.sourceProjectPath}'`),
      );
    });

    it('with expected merge request id', () => {
      expect(wrapper.find(GlModal).text()).toEqual(
        expect.stringContaining(`data-merge-request-id='${propsData.appMetadata.mergeRequestId}'`),
      );
    });

    it('with expected appUrl', () => {
      expect(wrapper.find(GlModal).text()).toEqual(
        expect.stringContaining(`data-mr-url='${propsData.appMetadata.appUrl}'`),
      );
    });

    it('with review app link', () => {
      expect(
        wrapper
          .find(GlModal)
          .find('a.js-review-app-link')
          .attributes('href'),
      ).toEqual(propsData.link);
    });

    it('tracks an event when review app link is clicked', () => {
      const spy = mockTracking('_category_', wrapper.element, jest.spyOn);
      const appLink = wrapper.find(GlModal).find('a.js-review-app-link');
      triggerEvent(appLink.element);

      expect(spy).toHaveBeenCalledWith('_category_', 'open_review_app', {
        label: 'review_app',
      });
    });
  });

  describe('renders the copyToClipboard button', () => {
    it('within the modal', () => {
      expect(wrapper.find(ModalCopyButton)).toBeTruthy();
    });

    it('with the expected modalId', () => {
      const renderedId = wrapper.find(GlModal).attributes('modalid');
      expect(wrapper.find(ModalCopyButton).props().modalId).toBe(renderedId);
    });
  });
});
