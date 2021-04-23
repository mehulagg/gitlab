import { GlCard } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { subscriptionDetailsFields } from 'ee/pages/admin/cloud_licenses/components/subscription_breakdown.vue';
import SubscriptionDetailsCard from 'ee/pages/admin/cloud_licenses/components/subscription_details_card.vue';
import SubscriptionDetailsTable from 'ee/pages/admin/cloud_licenses/components/subscription_details_table.vue';
import { useFakeDate } from 'helpers/fake_date';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { license } from '../mock_data';

describe('Subscription Details Card', () => {
  // March 16th, 2020
  useFakeDate(2021, 2, 16);

  let wrapper;

  const findCard = () => wrapper.findComponent(GlCard);
  const findCardHeader = () => findCard().find('.gl-card-header');
  const findCardFooter = () => findCard().find('.gl-card-footer');
  const findSubscriptionDetailsTable = () => wrapper.findComponent(SubscriptionDetailsTable);

  const createComponent = (
    { detailsFields = subscriptionDetailsFields, headerText, subscription = license.ULTIMATE } = {},
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
          value: 13,
        },
        {
          canCopy: false,
          label: 'Plan',
          value: 'Ultimate',
        },
        {
          canCopy: false,
          label: 'Renews',
          value: 'in 1 year',
        },
        {
          canCopy: false,
          label: 'Last Sync',
          value: 'just now',
        },
        {
          canCopy: false,
          label: 'Started',
          value: '11 March 2021',
        },
      ]);
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
