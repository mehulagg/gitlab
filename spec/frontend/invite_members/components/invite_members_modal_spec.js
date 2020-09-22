import { shallowMount } from '@vue/test-utils';
import { GlModal, GlDropdown, GlDropdownItem, GlDatepicker, GlSprintf, GlLink } from '@gitlab/ui';
import Api from '~/api';
import InviteMembersModal from '~/invite_members/components/invite_members_modal.vue';

const groupId = '1';
const groupName = 'testgroup';
const accessLevels = { Guest: 10, Reporter: 20, Developer: 30, Maintainer: 40, Owner: 50 };
const defaultAccessLevel = '10';
const helpLink = 'https://example.com';

const createComponent = () => {
  return shallowMount(InviteMembersModal, {
    propsData: {
      groupId,
      groupName,
      accessLevels,
      defaultAccessLevel,
      helpLink,
    },
    stubs: {
      GlSprintf,
    },
  });
};

describe('InviteMembersModal', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findModal = () => wrapper.find(GlModal);
  const findDropdown = () => wrapper.find(GlDropdown);
  const findDropdownItems = () => wrapper.findAll(GlDropdownItem);
  const findDatepicker = () => wrapper.find(GlDatepicker);
  const findLink = () => wrapper.find(GlLink);

  describe('rendering the modal', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('renders the modal with the correct attributes', () => {
      const expectedModalAttributes = {
        title: 'Invite team members',
        'ok-title': 'Invite',
        'cancel-title': 'Cancel',
      };

      expect(findModal().attributes()).toMatchObject(expectedModalAttributes);
    });

    describe('rendering the access levels dropdown', () => {
      it('sets the default dropdown text to the default access level name', () => {
        expect(findDropdown().attributes('text')).toBe('Guest');
      });

      it('renders dropdown items for each accessLevel', () => {
        expect(findDropdownItems()).toHaveLength(5);
      });
    });

    describe('rendering the help link', () => {
      it('renders the correct link', () => {
        expect(findLink().attributes('href')).toBe(helpLink);
      });
    });

    describe('rendering the access expiration date field', () => {
      it('renders the datepicker', () => {
        expect(findDatepicker()).toExist();
      });
    });
  });

  describe('submitting the invite form', () => {
    const postData = {
      user_id: '1',
      access_level: '10',
      expires_at: new Date(),
      format: 'json',
    };

    beforeEach(() => {
      wrapper = createComponent();

      jest.spyOn(Api, 'inviteGroupMember').mockResolvedValue({ data: postData });
      wrapper.vm.$toast = { show: jest.fn() };

      wrapper.vm.submitForm(postData);
    });

    it('calls Api inviteGroupMember with the correct params', () => {
      expect(Api.inviteGroupMember).toHaveBeenCalledWith(groupId, postData);
    });

    describe('when the invite was sent successfully', () => {
      const toastMessageSuccessful = 'Users were succesfully added';

      it('displays the successful toastMessage', () => {
        expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(
          toastMessageSuccessful,
          wrapper.vm.toastOptions,
        );
      });
    });
  });
});
