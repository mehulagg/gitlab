import { GlCard, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SubscriptionDetailsUserInfo, {
  billableUsersURL,
  trueUpURL,
} from 'ee/pages/admin/cloud_licenses/components/subscription_details_user_info.vue';
import {
  billableUsersText,
  maximumUsersText,
  usersInLicenseText,
  usersOverSubscriptionText,
} from 'ee/pages/admin/cloud_licenses/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { license } from '../mock_data';

describe('Subscription Details Card', () => {
  let wrapper;

  const getDataTestId = (data) => data.replace(/([A-Z])/g, (letter) => `-${letter.toLowerCase()}`);

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
    card                       | info    | title                        | text                         | link
    ${'usersInLicense'}        | ${'10'} | ${'Users in subscription'}   | ${usersInLicenseText}        | ${false}
    ${'billableUsers'}         | ${'8'}  | ${'Billable users'}          | ${billableUsersText}         | ${billableUsersURL}
    ${'maximumUsers'}          | ${'8'}  | ${'Maximum users'}           | ${maximumUsersText}          | ${false}
    ${'usersOverSubscription'} | ${'0'}  | ${'Users over subscription'} | ${usersOverSubscriptionText} | ${trueUpURL}
  `('with data for $card', ({ card, info, title, text, link }) => {
    beforeEach(() => {
      createComponent();
    });

    const testId = getDataTestId(card);
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
