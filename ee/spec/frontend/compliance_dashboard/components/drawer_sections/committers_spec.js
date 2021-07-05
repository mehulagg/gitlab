import { GlAvatarsInline, GlAvatarLink } from '@gitlab/ui';
import Committers from 'ee/compliance_dashboard/components/drawer_sections/committers.vue';
import DrawerSectionHeader from 'ee/compliance_dashboard/components/shared/drawer_section_header.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { createApprovers } from '../../mock_data';

describe('Committers component', () => {
  let wrapper;

  const findSectionHeader = () => wrapper.findComponent(DrawerSectionHeader);
  const findSubHeader = () => wrapper.findByTestId('committers-sub-header');
  const findCommitters = () => wrapper.findComponent(GlAvatarsInline);
  const findCommittersLink = () => wrapper.findComponent(GlAvatarLink);

  const createComponent = (committers) => {
    return shallowMountExtended(Committers, {
      propsData: { committers },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('rendering', () => {
    const committersList = createApprovers(2);

    beforeEach(() => {
      wrapper = createComponent(committersList);
    });

    it('renders the header', () => {
      expect(findSectionHeader().text()).toBe('Change made by');
    });

    it('renders the committers sub-header', () => {
      expect(findSubHeader().text()).toBe('2 commit authors');
    });

    it('renders the committers list', () => {
      expect(findCommitters().props()).toMatchObject({
        avatars: committersList,
      });
    });
  });

  describe('when only one committer', () => {
    const committersList = createApprovers(1);

    beforeEach(() => {
      wrapper = createComponent(committersList);
    });

    it('renders the header', () => {
      expect(findSectionHeader().text()).toBe('Change made by');
    });

    it('renders the committers sub-header in singular', () => {
      expect(findSubHeader().text()).toBe('1 commit author');
    });
  });
});
