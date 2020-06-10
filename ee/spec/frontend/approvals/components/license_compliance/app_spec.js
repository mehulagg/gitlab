import Vuex from 'vuex';
import { mount, createLocalVue } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import ApprovalsLicenseCompliance from 'ee/approvals/components/license_compliance/app.vue';
import ModalLicenseCompliance from 'ee/approvals/components/modal_license_compliance.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EE Approvals LicenseCompliance App', () => {
  let wrapper;
  let store;

  const fetchRulesMock = jest.fn();
  const openModalMock = jest.fn();

  const createStore = () => {
    const storeOptions = {
      actions: {
        fetchRules: fetchRulesMock,
      },
      modules: {
        createModal: {
          namespaced: true,
          actions: {
            open: openModalMock,
          },
        },
        approvals: {
          state: {
            isLoading: true,
            rules: [],
          },
        },
      },
    };

    store = new Vuex.Store(storeOptions);
  };

  const createWrapper = () => {
    wrapper = mount(ApprovalsLicenseCompliance, {
      localVue,
      store,
      stubs: {
        ModalLicenseCompliance,
      },
    });
  };

  beforeEach(() => {
    createStore();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findByHrefAttribute = href => wrapper.find(`[href="${href}"]`);
  const findOpenModalButton = () => wrapper.find('button[name="openModal"]');
  const findLoadingIndicator = () => wrapper.find('[aria-label="loading"]');
  const findInformationIcon = () => wrapper.find(GlIcon);

  describe('when created', () => {
    it('fetches approval rules', () => {
      expect(fetchRulesMock).not.toHaveBeenCalled();
      createWrapper();
      expect(fetchRulesMock).toHaveBeenCalledTimes(1);
    });
  });

  describe('when loading', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders the open-modal button with an active loading state', () => {
      expect(findOpenModalButton().props('loading')).toBe(true);
    });

    it('disables the open-modal button', () => {
      expect(findOpenModalButton().attributes('disabled')).toBeTruthy();
    });

    it('renders a loading indicator', () => {
      expect(findLoadingIndicator().exists()).toBe(true);
    });
  });

  describe('when data has loaded', () => {
    const docsLink = 'http://docs-link.com';

    beforeEach(() => {
      store.state.approvals.isLoading = false;
      store.state.approvals.docsLink = docsLink;

      createWrapper();
    });

    it('renders the open-modal button without an active loading state', () => {
      expect(findOpenModalButton().props('loading')).toBe(false);
    });

    it('does not render a loading indicator', () => {
      expect(findLoadingIndicator().exists()).toBe(false);
    });

    it('renders a information icon', () => {
      expect(findInformationIcon().props('name')).toBe('information');
    });

    it('opens the link to the documentation page in a new tab', () => {
      expect(findByHrefAttribute(docsLink).attributes('target')).toBe('_blank');
    });

    it('opens a model when the license-approval button is clicked', async () => {
      expect(openModalMock).not.toHaveBeenCalled();

      await findOpenModalButton().trigger('click');

      expect(openModalMock).toHaveBeenCalled();
    });
  });
});
