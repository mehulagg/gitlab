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
    const linkDescriptionPart = link ? ' ' : ' not ';

    it(`displays the info`, () => {
      expect(findUseCard().find('h2').text()).toBe(info);
    });

    it(`displays the title`, () => {
      expect(findUseCard().find('h5').text()).toBe(title);
    });

    it(`displays the content`, () => {
      if (link) {
        expect(findUseCard().findComponent(GlSprintf).attributes('message')).toBe(text);
      } else {
        expect(findUseCard().find('p').text()).toBe(text);
      }
    });

    it(`has${linkDescriptionPart}a link`, () => {
      createComponent({}, true);

      if (link) {
        expect(findUseCard().findComponent(GlLink).attributes('href')).toBe(link);
      } else {
        expect(findUseCard().findComponent(GlLink).exists()).toBe(link);
      }
    });
  });
});
