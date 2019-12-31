import { mount } from '@vue/test-utils';
import component from 'ee/vue_shared/security_reports/components/dismissal_comment_modal_footer.vue';
import Tracking from '~/tracking';
import LoadingButton from '~/vue_shared/components/loading_button.vue';

jest.mock('~/tracking');

describe('DismissalCommentModalFooter', () => {
  let origPage;
  let wrapper;

  afterEach(() => {
    document.body.dataset.page = origPage;
    wrapper.destroy();
  });

  beforeEach(() => {
    origPage = document.body.dataset.page;
    document.body.dataset.page = '_track_category_';
  });

  describe('with an non-dismissed vulnerability', () => {
    beforeEach(() => {
      wrapper = mount(component, { sync: false });
    });

    it('should render the "Add comment and dismiss" button', () => {
      expect(wrapper.find(LoadingButton).text()).toBe('Add comment & dismiss');
    });

    it('should emit the "addCommentAndDismiss" event when clicked', () => {
      wrapper.find(LoadingButton).trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted().addCommentAndDismiss).toBeTruthy();
        expect(Tracking.event).toHaveBeenCalledWith(
          '_track_category_',
          'click_add_comment_and_dismiss',
        );
      });
    });

    it('should emit the cancel event when the cancel button is clicked', () => {
      wrapper.find('.js-cancel').trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted().cancel).toBeTruthy();
      });
    });
  });

  describe('with an already dismissed vulnerability', () => {
    describe('and adding a comment', () => {
      beforeEach(() => {
        const propsData = {
          isDismissed: true,
        };
        wrapper = mount(component, { propsData });
      });

      it('should render the "Add comment and dismiss" button', () => {
        expect(wrapper.find(LoadingButton).text()).toBe('Add comment');
      });

      it('should emit the "addCommentAndDismiss" event when clicked', () => {
        wrapper.find(LoadingButton).trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted().addDismissalComment).toBeTruthy();
          expect(Tracking.event).toHaveBeenCalledWith('_track_category_', 'click_add_comment');
        });
      });
    });

    describe('and editing a comment', () => {
      beforeEach(() => {
        const propsData = {
          isDismissed: true,
          isEditingExistingFeedback: true,
        };
        wrapper = mount(component, { propsData });
      });

      it('should render the "Save comment" button', () => {
        expect(wrapper.find(LoadingButton).text()).toBe('Save comment');
      });

      it('should emit the "addCommentAndDismiss" event when clicked', () => {
        wrapper.find(LoadingButton).trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emitted().addDismissalComment).toBeTruthy();
          expect(Tracking.event).toHaveBeenCalledWith('_track_category_', 'click_edit_comment');
        });
      });
    });
  });
});
