import { mount, createLocalVue } from '@vue/test-utils';
import { merge } from 'lodash';
import { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import SubscriptionDetails from 'ee/subscriptions/buy_minutes/components/checkout/subscription_details.vue';
import subscriptionsResolvers from 'ee/subscriptions/buy_minutes/graphql/resolvers';
import stateQuery from 'ee/subscriptions/graphql/queries/state.query.graphql';
import { NEW_GROUP } from 'ee/subscriptions/new/constants';
import Step from 'ee/vue_shared/purchase_flow/components/step.vue';
import purchaseFlowResolvers from 'ee/vue_shared/purchase_flow/graphql/resolvers';
import {
  stateData as initialStateData,
  mockParsedNamespaces,
  mockCiMinutesPlans,
} from 'ee_jest/subscriptions/buy_minutes/mock_data';
import createMockApollo from 'helpers/mock_apollo_helper';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Subscription Details', () => {
  const resolvers = { ...purchaseFlowResolvers, ...subscriptionsResolvers };
  let wrapper;

  const createMockApolloProvider = (stateData = {}) => {
    const mockApollo = createMockApollo([], resolvers);

    const data = merge({}, initialStateData, stateData);

    mockApollo.clients.defaultClient.cache.writeQuery({
      query: stateQuery,
      data,
    });

    return mockApollo;
  };

  const createComponent = (stateData = {}) => {
    const apolloProvider = createMockApolloProvider(stateData);

    return mount(SubscriptionDetails, {
      localVue,
      apolloProvider,
      propsData: {
        plans: mockCiMinutesPlans,
      },
      stubs: {
        Step,
      },
    });
  };

  const organizationNameInput = () => wrapper.find({ ref: 'organization-name' });
  const groupSelect = () => wrapper.find({ ref: 'group-select' });
  const numberOfUsersInput = () => wrapper.find({ ref: 'number-of-users' });
  const companyLink = () => wrapper.find({ ref: 'company-link' });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('A new user setting up for personal use', () => {
    beforeEach(() => {
      wrapper = createComponent({ isNewUser: true, isSetupForCompany: false });
    });

    it('should not display an input field for the company or group name', () => {
      expect(organizationNameInput().exists()).toBe(false);
    });

    it('should not display the group select', () => {
      expect(groupSelect().exists()).toBe(false);
    });

    it('should disable the number of users input field', () => {
      expect(numberOfUsersInput().attributes('disabled')).toBeDefined();
    });

    it('should set the min number of users to 1', () => {
      expect(numberOfUsersInput().attributes('min')).toBe('1');
    });

    it('should show a link to change to setting up for a company', () => {
      expect(companyLink().exists()).toBe(true);
    });
  });

  describe('A new user setting up for a company or group', () => {
    beforeEach(() => {
      wrapper = createComponent({ isNewUser: true, isSetupForCompany: true, namespaces: [] });
    });

    it('should display an input field for the company or group name', () => {
      expect(organizationNameInput().exists()).toBe(true);
    });

    it('should not display the group select', () => {
      expect(groupSelect().exists()).toBe(false);
    });

    it('should enable the number of users input field', () => {
      expect(numberOfUsersInput().attributes('disabled')).toBeUndefined();
    });

    it('should set the min number of users to 1', () => {
      expect(numberOfUsersInput().attributes('min')).toBe('1');
    });

    it('should not show a link to change to setting up for a company', () => {
      expect(companyLink().exists()).toBe(false);
    });
  });

  describe('An existing user without any groups', () => {
    beforeEach(() => {
      wrapper = createComponent({ isNewUser: false, namespaces: [] });
    });

    it('should display an input field for the company or group name', () => {
      expect(organizationNameInput().exists()).toBe(true);
    });

    it('should not display the group select', () => {
      expect(groupSelect().exists()).toBe(false);
    });

    it('should enable the number of users input field', () => {
      expect(numberOfUsersInput().attributes('disabled')).toBeUndefined();
    });

    it('should set the min number of users to 1', () => {
      expect(numberOfUsersInput().attributes('min')).toBe('1');
    });

    it('should not show a link to change to setting up for a company', () => {
      expect(companyLink().exists()).toBe(false);
    });
  });

  describe('An existing user with groups', () => {
    beforeEach(() => {
      wrapper = createComponent({ isNewUser: false, namespaces: mockParsedNamespaces });
    });

    it('should not display an input field for the company or group name', () => {
      expect(organizationNameInput().exists()).toBe(false);
    });

    it('should display the group select', () => {
      expect(groupSelect().exists()).toBe(true);
    });

    it('should enable the number of users input field', () => {
      expect(numberOfUsersInput().attributes('disabled')).toBeUndefined();
    });

    it('should set the min number of users to 1', () => {
      expect(numberOfUsersInput().attributes('min')).toBe('1');
    });

    it('should not show a link to change to setting up for a company', () => {
      expect(companyLink().exists()).toBe(false);
    });
  });

  describe('selecting an existing group', () => {
    beforeEach(() => {
      wrapper = createComponent({
        subscription: { namespaceId: 483 },
        namespaces: mockParsedNamespaces,
      });
    });

    it('should display the correct description', () => {
      expect(wrapper.text()).toContain('Your subscription will be applied to this group');
    });

    it('should set the min number of users to 12', () => {
      expect(numberOfUsersInput().attributes('min')).toBe('12');
    });
  });

  describe('selecting "Create a new group', () => {
    beforeEach(() => {
      wrapper = createComponent({
        subscription: { namespaceId: NEW_GROUP },
        namespaces: mockParsedNamespaces,
      });
    });

    it('should display the correct description', () => {
      expect(wrapper.text()).toContain("You'll create your new group after checkout");
    });

    it('should display an input field for the company or group name', () => {
      expect(organizationNameInput().exists()).toBe(true);
    });

    it('should set the min number of users to 1', () => {
      expect(numberOfUsersInput().attributes('min')).toBe('1');
    });
  });

  describe('An existing user coming from group billing page', () => {
    beforeEach(() => {
      wrapper = createComponent({
        isNewUser: false,
        isSetupForCompany: true,
        subscription: { namespaceId: 132 },
        namespaces: mockParsedNamespaces,
      });
    });

    it('should not display an input field for the company or group name', () => {
      expect(organizationNameInput().exists()).toBe(false);
    });

    it('should display the group select', () => {
      expect(groupSelect().exists()).toBe(true);
    });

    it('should enable the number of users input field', () => {
      expect(numberOfUsersInput().attributes('disabled')).toBeUndefined();
    });

    it('should set the min number of users to 3', () => {
      expect(numberOfUsersInput().attributes('min')).toBe('3');
    });

    it('should set the selected group to initial namespace id', () => {
      expect(groupSelect().element.value).toBe('132');
    });

    it('should not show a link to change to setting up for a company', () => {
      expect(companyLink().exists()).toBe(false);
    });

    describe('selecting an existing group', () => {
      beforeEach(() => {
        wrapper = createComponent({
          subscription: { namespaceId: 483 },
          namespaces: mockParsedNamespaces,
        });
      });

      it('should display the correct description', () => {
        expect(wrapper.text()).toContain('Your subscription will be applied to this group');
      });

      it('should set the min number of users to 12', () => {
        expect(numberOfUsersInput().attributes('min')).toBe('12');
      });

      it('should set the selected group to the user selected namespace id', () => {
        expect(groupSelect().element.value).toBe('483');
      });
    });
  });

  describe('validations', () => {
    const isStepValid = () => wrapper.find(Step).props('isValid');

    describe('when setting up for a company', () => {
      it('should be valid', () => {
        wrapper = createComponent({
          subscription: { namespaceId: 483, quantity: 14 },
          selectedPlanId: 'firstPlanId',
          customer: { company: 'Organization name' },
        });

        expect(isStepValid()).toBe(true);
      });

      it('should be invalid when no organization name is given, and no group is selected', async () => {
        wrapper = createComponent({
          isSetupForCompany: true,
          subscription: { namespaceId: null },
          customer: { company: null },
        });

        await nextTick();

        expect(isStepValid()).toBe(false);
      });

      it('should be invalid when number of users is 0', async () => {
        wrapper = createComponent({
          isSetupForCompany: true,
          subscription: { quantity: 0 },
        });

        await nextTick();

        expect(isStepValid()).toBe(false);
      });

      it('should be invalid when number of users is smaller than the selected group users', async () => {
        wrapper = createComponent({
          isSetupForCompany: true,
          subscription: { namespaceId: 483, quantity: 10 },
        });

        await nextTick();

        expect(isStepValid()).toBe(false);
      });
    });

    describe('when not setting up for a company', () => {
      beforeEach(() => {
        wrapper = createComponent({
          isSetupForCompany: false,
          subscription: { namespaceId: 483, quantity: 1 },
          selectedPlanId: 'firstPlanId',
          customer: { company: 'Organization name' },
        });
      });

      it('should be valid', () => {
        expect(isStepValid()).toBe(true);
      });

      it('should be invalid when no number of users is 0', async () => {
        wrapper = createComponent({
          isSetupForCompany: false,
          subscription: { namespaceId: 483, quantity: 0 },
          selectedPlanId: 'firstPlanId',
          customer: { company: 'Organization name' },
        });

        await nextTick();

        expect(isStepValid()).toBe(false);
      });

      it('should be invalid when no number of users is greater than 1', async () => {
        wrapper = createComponent({
          isSetupForCompany: false,
          subscription: { namespaceId: 483, quantity: 2 },
          selectedPlanId: 'firstPlanId',
          customer: { company: 'Organization name' },
        });

        await nextTick();

        expect(isStepValid()).toBe(false);
      });
    });
  });
});
