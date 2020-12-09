import { GlLink, GlPopover } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import MoreInfo from '~/vue_shared/security_reports/components/more_info.vue';

const helpPath = '/docs';
const discoverProjectSecurityPath = '/discoverProjectSecurityPath';

describe('MoreInfo component', () => {
  let wrapper;

  const createWrapper = props => {
    wrapper = shallowMount(MoreInfo, {
      propsData: {
        helpPath,
        ...props,
      },
    });
  };

  const findLink = () => wrapper.find(GlLink);
  const findPopover = () => wrapper.find(GlPopover);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('given a help path only', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('does not render a popover', () => {
      expect(findPopover().exists()).toBe(false);
    });

    it('renders a help link', () => {
      expect(findLink().attributes()).toMatchObject({
        href: helpPath,
        target: '_blank',
      });
    });
  });

  describe('given a help path and discover project security path', () => {
    beforeEach(() => {
      createWrapper({ discoverProjectSecurityPath });
    });

    it('renders a popover', () => {
      const popover = findPopover();
      expect(popover.attributes()).toMatchObject({
        title: MoreInfo.i18n.upgradeToManageVulnerabilities,
        triggers: 'click blur',
      });
      expect(popover.text()).toContain(MoreInfo.i18n.upgradeToInteract);
    });

    it('renders a link to the discover path', () => {
      expect(findLink().attributes()).toMatchObject({
        href: discoverProjectSecurityPath,
        target: '_blank',
      });
    });
  });
});
