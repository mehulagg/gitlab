import { mount } from '@vue/test-utils';
import StorageApp from 'ee/storage_counter/components/app.vue';
import Project from 'ee/storage_counter/components/project.vue';
import StorageInlineAlert from 'ee/storage_counter/components/storage_inline_alert.vue';
import UsageGraph from 'ee/storage_counter/components/usage_graph.vue';
import UsageStatistics from 'ee/storage_counter/components/usage_statistics.vue';
import TemporaryStorageIncreaseModal from 'ee/storage_counter/components/temporary_storage_increase_modal.vue';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import { namespaceData, withRootStorageStatistics } from '../mock_data';
import { numberToHumanSize } from '~/lib/utils/number_utils';

const TEST_LIMIT = 1000;

describe('Storage counter app', () => {
  let wrapper;

  const findTotalUsage = () => wrapper.find("[data-testid='total-usage']");
  const findPurchaseStorageLink = () => wrapper.find("[data-testid='purchase-storage-link']");
  const findTemporaryStorageIncreaseButton = () =>
    wrapper.find("[data-testid='temporary-storage-increase-button']");
  const findUsageGraph = () => wrapper.find(UsageGraph);
  const findUsageStatistics = () => wrapper.find(UsageStatistics);
  const findStorageInlineAlert = () => wrapper.find(StorageInlineAlert);

  const createComponent = ({
    props = {},
    loading = false,
    additionalRepoStorageByNamespace = false,
  } = {}) => {
    const $apollo = {
      queries: {
        namespace: {
          loading,
        },
      },
    };

    wrapper = mount(StorageApp, {
      propsData: { namespacePath: 'h5bp', helpPagePath: 'help', ...props },
      mocks: { $apollo },
      directives: {
        GlModalDirective: createMockDirective(),
      },
      provide: {
        glFeatures: {
          additionalRepoStorageByNamespace,
        },
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the 2 projects', async () => {
    wrapper.setData({
      namespace: namespaceData,
    });

    await wrapper.vm.$nextTick();

    expect(wrapper.findAll(Project)).toHaveLength(3);
  });

  describe('limit', () => {
    it('when limit is set it renders limit information', async () => {
      wrapper.setData({
        namespace: namespaceData,
      });

      await wrapper.vm.$nextTick();

      expect(wrapper.text()).toContain(numberToHumanSize(namespaceData.limit));
    });

    it('when limit is 0 it does not render limit information', async () => {
      wrapper.setData({
        namespace: { ...namespaceData, limit: 0 },
      });

      await wrapper.vm.$nextTick();

      expect(wrapper.text()).not.toContain(numberToHumanSize(0));
    });
  });

  describe('with rootStorageStatistics information', () => {
    it('renders total usage', async () => {
      wrapper.setData({
        namespace: withRootStorageStatistics,
      });

      await wrapper.vm.$nextTick();

      expect(findTotalUsage().text()).toContain(withRootStorageStatistics.totalUsage);
    });
  });

  describe('with additional_repo_storage_by_namespace feature flag', () => {
    it('usage_graph component hidden is when flag is false', async () => {
      wrapper.setData({
        namespace: withRootStorageStatistics,
      });

      await wrapper.vm.$nextTick();

      expect(findUsageGraph().exists()).toBe(true);
      expect(findUsageStatistics().exists()).toBe(false);
      expect(findStorageInlineAlert().exists()).toBe(false);
    });

    it('usage_statistics component is rendered when flag is true', async () => {
      createComponent({
        additionalRepoStorageByNamespace: true,
        loading: true,
      });

      wrapper.setData({
        namespace: withRootStorageStatistics,
      });

      wrapper.vm.$apollo.queries.namespace.loading = false;

      await wrapper.vm.$nextTick();

      expect(findUsageStatistics().exists()).toBe(true);
      expect(findUsageGraph().exists()).toBe(false);
      expect(findStorageInlineAlert().exists()).toBe(true);
    });
  });

  describe('without rootStorageStatistics information', () => {
    it('renders N/A', async () => {
      wrapper.setData({
        namespace: namespaceData,
      });

      await wrapper.vm.$nextTick();

      expect(findTotalUsage().text()).toContain('N/A');
    });
  });

  describe('purchase storage link', () => {
    describe('when purchaseStorageUrl is not set', () => {
      it('does not render an additional link', () => {
        expect(findPurchaseStorageLink().exists()).toBe(false);
      });
    });

    describe('when purchaseStorageUrl is set', () => {
      beforeEach(() => {
        createComponent({ props: { purchaseStorageUrl: 'customers.gitlab.com' } });
      });

      it('does render link', () => {
        const link = findPurchaseStorageLink();

        expect(link).toExist();
        expect(link.attributes('href')).toBe('customers.gitlab.com');
      });
    });
  });

  describe('temporary storage increase', () => {
    describe.each`
      props                                             | isVisible
      ${{}}                                             | ${false}
      ${{ isTemporaryStorageIncreaseVisible: 'false' }} | ${false}
      ${{ isTemporaryStorageIncreaseVisible: 'true' }}  | ${true}
    `('with $props', ({ props, isVisible }) => {
      beforeEach(() => {
        createComponent({ props });
      });

      it(`renders button = ${isVisible}`, () => {
        expect(findTemporaryStorageIncreaseButton().exists()).toBe(isVisible);
      });
    });

    describe('when temporary storage increase is visible', () => {
      beforeEach(() => {
        createComponent({ props: { isTemporaryStorageIncreaseVisible: 'true' } });
        wrapper.setData({
          namespace: {
            ...namespaceData,
            limit: TEST_LIMIT,
          },
        });
      });

      it('binds button to modal', () => {
        const { value } = getBinding(
          findTemporaryStorageIncreaseButton().element,
          'gl-modal-directive',
        );

        // Check for truthiness so we're assured we're not comparing two undefineds
        expect(value).toBeTruthy();
        expect(value).toEqual(StorageApp.modalId);
      });

      it('renders modal', () => {
        expect(wrapper.find(TemporaryStorageIncreaseModal).props()).toEqual({
          limit: numberToHumanSize(TEST_LIMIT),
          modalId: StorageApp.modalId,
        });
      });
    });
  });
});
