import { mount } from '@vue/test-utils';
import DismissalCommentBox from 'ee/vue_shared/security_reports/components/dismissal_comment_box.vue';
import component from 'ee/vue_shared/security_reports/components/dismissal_comment_box_toggle.vue';

describe('DismissalCommentBox', () => {
  let wrapper;

  describe('when the box is inactive', () => {
    beforeEach(() => {
      wrapper = mount(component, {
        sync: false,
      });
    });

    it('should render the placeholder text box', () => {
      expect(wrapper.find('.js-comment-placeholder').exists()).toBeTruthy();
    });

    it('should not render the dismissal comment box', () => {
      expect(wrapper.find(DismissalCommentBox).exists()).toBeFalsy();
    });
  });

  describe('when the box is active', () => {
    beforeEach(() => {
      wrapper = mount(component, {
        sync: false,

        propsData: {
          isActive: true,
        },
      });
    });

    it('should render the dismissal comment box', () => {
      expect(wrapper.find(DismissalCommentBox).exists()).toBeTruthy();
    });

    it('should not render the placeholder text box', () => {
      expect(wrapper.find('.js-comment-placeholder').exists()).toBeFalsy();
    });
  });
});
