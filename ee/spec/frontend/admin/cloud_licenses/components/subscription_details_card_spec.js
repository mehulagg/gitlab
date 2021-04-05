import { GlCard } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubscriptionDetailsCard from 'ee/pages/admin/cloud_licenses/components/subscription_details_card.vue';
import SubscriptionDetailsTable from 'ee/pages/admin/cloud_licenses/components/subscription_details_table.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { license } from '../mock_data';

describe('Subscription Details Card', () => {
  let wrapper;

  const findCard = () => wrapper.findComponent(GlCard);
  const findCardHeader = () => findCard().find('.gl-card-header');
  const findCardFooter = () => findCard().find('.gl-card-footer');
  const findSubscriptionDetailsTable = () => wrapper.findComponent(SubscriptionDetailsTable);

  const createComponent = (
    { detailsFields = ['id', 'plan'], headerText, subscription = license.ULTIMATE } = {},
    slots,
  ) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionDetailsCard, {
        propsData: {
          detailsFields,
          headerText,
          subscription,
        },
        stubs: {
          GlCard,
        },
        slots,
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with data', () => {
    beforeEach(() => {
      createComponent({
        headerText: 'Card header title',
      });
    });

    it('displays a title', () => {
      expect(findCard().text()).toBe('Card header title');
    });

    it('displays the details table component', () => {
      expect(findSubscriptionDetailsTable().exists()).toBe(true);
    });

    it('passes the details to the table component', () => {
      expect(findSubscriptionDetailsTable().props('details')).toEqual([
        {
          canCopy: true,
          label: 'ID',
          value: '1309188',
        },
        {
          canCopy: false,
          label: 'Plan',
          value: 'Ultimate',
        },
      ]);
    });
  });

  describe('with empty subscription', () => {
    it('passes an empty array to the table component', () => {
      createComponent({ subscription: {} });

      expect(findSubscriptionDetailsTable().props('details')).toEqual([]);
    });
  });

  describe('with no title', () => {
    it('does not display a title', () => {
      createComponent();

      expect(findCardHeader().exists()).toBe(false);
    });
  });

  describe('with footer', () => {
    beforeEach(() => {
      createComponent(
        {},
        {
          footer: '<div>Footer content</div>',
        },
      );
    });

    it('displays the footer', () => {
      expect(findCardFooter().exists()).toBe(true);
    });

    it('displays the footer text', () => {
      expect(findCardFooter().text()).toContain('Footer content');
    });
  });
});
