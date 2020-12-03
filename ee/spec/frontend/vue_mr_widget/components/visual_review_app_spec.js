import { GlButton, GlDropdown, GlModal } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import VisualReviewAppLink from 'ee/vue_merge_request_widget/components/visual_review_app_link.vue';
import { mockTracking, triggerEvent } from 'helpers/tracking_helper';
import ModalCopyButton from '~/vue_shared/components/modal_copy_button.vue';

const propsData = {
  cssClass: 'button cool-button best-button',
  appMetadata: {
    mergeRequestId: 1,
    sourceProjectId: 20,
    appUrl: 'http://gitlab.example.com',
    sourceProjectPath: 'source/project',
  },
  viewAppDisplay: {
    text: 'View app',
    tooltip: '',
  },
  link: 'http://example.com',
};

describe('Visual Review App Link', () => {
  let wrapper;

  const factory = (options = {}) => {
    wrapper = mount(VisualReviewAppLink, {
      ...options,
    });
  };

  const openModal = () => {
    wrapper.find('.js-review-button').trigger('click');
  };

  const findModal = () => wrapper.find(GlModal);

  beforeEach(() => {
    factory({
      propsData,
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('renders link and text', () => {
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
      openModal();
    });

    it('with expected project Id', () => {
      expect(findModal().text()).toEqual(
        expect.stringContaining(`data-project-id='${propsData.appMetadata.sourceProjectId}'`),
      );
    });

    it('with expected project path', () => {
      expect(findModal().text()).toEqual(
        expect.stringContaining(`data-project-path='${propsData.appMetadata.sourceProjectPath}'`),
      );
    });

    it('with expected merge request id', () => {
      expect(findModal().text()).toEqual(
        expect.stringContaining(`data-merge-request-id='${propsData.appMetadata.mergeRequestId}'`),
      );
    });

    it('with expected appUrl', () => {
      expect(findModal().text()).toEqual(
        expect.stringContaining(`data-mr-url='${propsData.appMetadata.appUrl}'`),
      );
    });

    describe('renders the copyToClipboard button', () => {
      it('within the modal', () => {
        expect(wrapper.find(ModalCopyButton).exists()).toEqual(true);
      });

      it('with the expected modalId', () => {
        const { modalId } = findModal().props();
        expect(wrapper.find(ModalCopyButton).props().modalId).toBe(modalId);
      });
    });

    describe('renders modal footer', () => {
      describe('when no changes are listed', () => {
        it('with review app link', () => {
          expect(wrapper.find('a.js-deploy-url').attributes('href')).toEqual(propsData.link);
        });

        it('tracks an event when review app link is clicked', () => {
          const spy = mockTracking('_category_', wrapper.element, jest.spyOn);
          const appLink = findModal().find('a.js-deploy-url');
          triggerEvent(appLink.element);

          expect(spy).toHaveBeenCalledWith('_category_', 'open_review_app', {
            label: 'review_app',
          });
        });
      });

      describe('when changes are listed', () => {
        beforeEach(() => {
          factory({
            propsData: {
              ...propsData,
              changes: [
                {
                  path: '/example-path',
                  external_url: `${propsData.link}/example-path`,
                },
              ],
            },
          });
          openModal();
        });

        it('with review app split dropdown', () => {
          expect(
            wrapper
              .find(GlDropdown)
              .find(`a[href='${propsData.link}']`)
              .exists(),
          ).toEqual(true);
        });

        it('contains a list of changed pages', () => {
          expect(
            wrapper
              .find(GlDropdown)
              .find(`a[href='${propsData.link}/example-path']`)
              .exists(),
          ).toEqual(true);
        });

        it('tracks an event when review app link is clicked', () => {
          const spy = mockTracking('_category_', wrapper.element, jest.spyOn);
          const appLink = findModal().find(`a[href='${propsData.link}/example-path']`);
          triggerEvent(appLink.element);

          expect(spy).toHaveBeenCalledWith('_category_', 'open_review_app', {
            label: 'review_app',
          });
        });
      });
    });
  });
});
