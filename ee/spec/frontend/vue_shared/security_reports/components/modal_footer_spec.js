import { mount } from '@vue/test-utils';
import component from 'ee/vue_shared/security_reports/components/modal_footer.vue';
import SplitButton from 'ee/vue_shared/security_reports/components/split_button.vue';
import DismissButton from 'ee/vue_shared/security_reports/components/dismiss_button.vue';
import createState from 'ee/vue_shared/security_reports/store/state';
import LoadingButton from '~/vue_shared/components/loading_button.vue';

describe('Security Reports modal footer', () => {
  let wrapper;

  const mountComponent = options => {
    wrapper = mount(component, { sync: false, attachToDocument: true, ...options });
  };

  describe('can only create issue', () => {
    beforeEach(() => {
      const propsData = {
        modal: createState().modal,
        canCreateIssue: true,
      };
      mountComponent({ propsData });
    });

    it('does not render dismiss button', () => {
      expect(wrapper.find('.js-dismiss-btn').exists()).toBe(false);
    });

    it('only renders the create issue button', () => {
      expect(wrapper.vm.actionButtons[0].name).toBe('Create issue');
      expect(wrapper.find(LoadingButton).props('label')).toBe('Create issue');
    });

    it('emits createIssue when create issue button is clicked', () => {
      wrapper.find(LoadingButton).trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted().createNewIssue).toBeTruthy();
      });
    });
  });

  describe('can only create merge request', () => {
    beforeEach(() => {
      const propsData = {
        modal: createState().modal,
        canCreateMergeRequest: true,
      };
      mountComponent({ propsData });
    });

    it('only renders the create merge request button', () => {
      expect(wrapper.vm.actionButtons[0].name).toBe('Resolve with merge request');
      expect(wrapper.find(LoadingButton).props('label')).toBe('Resolve with merge request');
    });

    it('emits createMergeRequest when create merge request button is clicked', () => {
      wrapper.find(LoadingButton).trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted().createMergeRequest).toBeTruthy();
      });
    });
  });

  describe('can download download patch', () => {
    beforeEach(() => {
      const propsData = {
        modal: createState().modal,
        canDownloadPatch: true,
      };
      mountComponent({ propsData });
    });

    it('renders the download patch button', () => {
      expect(wrapper.vm.actionButtons[0].name).toBe('Download patch to resolve');
      expect(wrapper.find(LoadingButton).props('label')).toBe('Download patch to resolve');
    });

    it('emits downloadPatch when download patch button is clicked', () => {
      wrapper.find(LoadingButton).trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted().downloadPatch).toBeTruthy();
      });
    });
  });

  describe('can create merge request and issue', () => {
    beforeEach(() => {
      const propsData = {
        modal: createState().modal,
        canCreateIssue: true,
        canCreateMergeRequest: true,
      };
      mountComponent({ propsData });
    });

    it('renders create merge request and issue button as a split button', () => {
      expect(wrapper.contains('.js-split-button')).toBe(true);
      expect(wrapper.vm.actionButtons.length).toBe(2);
      expect(wrapper.find(SplitButton).exists()).toBe(true);
      expect(wrapper.find('.js-split-button').text()).toContain('Resolve with merge request');
      expect(wrapper.find('.js-split-button').text()).toContain('Create issue');
    });
  });

  describe('can create merge request, issue, and download patch', () => {
    beforeEach(() => {
      const propsData = {
        modal: createState().modal,
        canCreateIssue: true,
        canCreateMergeRequest: true,
        canDownloadPatch: true,
      };
      mountComponent({ propsData });
    });

    it('renders the split button', () => {
      expect(wrapper.vm.actionButtons.length).toBe(3);
      expect(wrapper.find(SplitButton).exists()).toBe(true);
      expect(wrapper.find('.js-split-button').text()).toContain('Resolve with merge request');
      expect(wrapper.find('.js-split-button').text()).toContain('Create issue');
      expect(wrapper.find('.js-split-button').text()).toContain('Download patch to resolve');
    });
  });

  describe('with dismissable vulnerability', () => {
    beforeEach(() => {
      const propsData = {
        modal: createState().modal,
        canDismissVulnerability: true,
      };
      mountComponent({ propsData });
    });

    it('should render the dismiss button', () => {
      expect(wrapper.find(DismissButton).exists()).toBe(true);
    });
  });
});
