import { GlCard, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubscriptionDetailsUserInfo, {
  billableUsersURL,
  trueUpURL,
} from 'ee/pages/admin/cloud_licenses/components/subscription_details_user_info.vue';
import {
  billableUsersText,
  billableUsersTitle,
  maximumUsersText,
  maximumUsersTitle,
  usersInSubscriptionText,
  usersInSubscriptionTitle,
  usersOverSubscriptionText,
  usersOverSubscriptionTitle,
} from 'ee/pages/admin/cloud_licenses/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { license } from '../mock_data';

describe('Subscription Details Card', () => {
  let wrapper;

  const itif = (condition) => (condition ? it : it.skip);

  const createComponent = (props = {}, stubGlSprintf = false) => {
    wrapper = extendedWrapper(
      shallowMount(SubscriptionDetailsUserInfo, {
        propsData: {
          subscription: license.ULTIMATE,
          ...props,
        },
        stubs: {
          GlCard,
          GlSprintf: stubGlSprintf ? GlSprintf : true,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe.each`
    testId                       | info    | title                         | text                         | link
    ${'users-in-license'}        | ${'10'} | ${usersInSubscriptionTitle}   | ${usersInSubscriptionText}   | ${false}
    ${'billable-users'}          | ${'8'}  | ${billableUsersTitle}         | ${billableUsersText}         | ${billableUsersURL}
    ${'maximum-users'}           | ${'8'}  | ${maximumUsersTitle}          | ${maximumUsersText}          | ${false}
    ${'users-over-subscription'} | ${'0'}  | ${usersOverSubscriptionTitle} | ${usersOverSubscriptionText} | ${trueUpURL}
  `('with data for $card', ({ testId, info, title, text, link }) => {
    beforeEach(() => {
      createComponent();
    });

    const findUseCard = () => wrapper.findByTestId(testId);

    it(`displays the info`, () => {
      expect(findUseCard().find('h2').text()).toBe(info);
    });

    it(`displays the title`, () => {
      expect(findUseCard().find('h5').text()).toBe(title);
    });

    itif(link)(`displays the content with a link`, () => {
      expect(findUseCard().findComponent(GlSprintf).attributes('message')).toBe(text);
    });

    itif(!link)('displays a simple content', () => {
      expect(findUseCard().find('p').text()).toBe(text);
    });

    itif(link)(`has a link`, () => {
      createComponent({}, true);
      expect(findUseCard().findComponent(GlLink).attributes('href')).toBe(link);
    });

    itif(!link)(`has not a link`, () => {
      createComponent({}, true);
      expect(findUseCard().findComponent(GlLink).exists()).toBe(link);
    });
  });
});
