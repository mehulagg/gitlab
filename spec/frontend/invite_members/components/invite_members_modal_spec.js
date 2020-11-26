import { shallowMount } from '@vue/test-utils';
import { GlDropdown, GlDropdownItem, GlDatepicker, GlSprintf, GlLink, GlModal } from '@gitlab/ui';
import { stubComponent } from 'helpers/stub_component';
import Api from '~/api';
import InviteMembersModal from '~/invite_members/components/invite_members_modal.vue';

const id = '1';
const name = 'testgroup';
const isProject = false;
const accessLevels = { Guest: 10, Reporter: 20, Developer: 30, Maintainer: 40, Owner: 50 };
const defaultAccessLevel = '10';
const helpLink = 'https://example.com';

const createComponent = (data = {}) => {
  return shallowMount(InviteMembersModal, {
    propsData: {
      id,
      name,
      isProject,
      accessLevels,
      defaultAccessLevel,
      helpLink,
    },
    data() {
      return data;
    },
    stubs: {
      GlModal: stubComponent(GlModal, {
        template:
          '<div><slot name="modal-title"></slot><slot></slot><slot name="modal-footer"></slot></div>',
      }),
      GlDropdown: true,
      GlDropdownItem: true,
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

  const findDropdown = () => wrapper.find(GlDropdown);
  const findDropdownItems = () => findDropdown().findAll(GlDropdownItem);
  const findDatepicker = () => wrapper.find(GlDatepicker);
  const findLink = () => wrapper.find(GlLink);
  const findCancelButton = () => wrapper.find({ ref: 'cancelButton' });
  const findInviteButton = () => wrapper.find({ ref: 'inviteButton' });

  describe('rendering the modal', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('renders the modal with the correct title', () => {
      expect(wrapper.attributes('title')).toBe('Invite team members');
    });

    it('renders the Cancel button text correctly', () => {
      expect(findCancelButton().text()).toBe('Cancel');
    });

    it('renders the Invite button text correctly', () => {
      expect(findInviteButton().text()).toBe('Invite');
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
    const apiErrorMessage = 'Member already exists';
    const genericErrorMessage = 'Some of the members could not be added';

    const toastMessageSuccessful = 'Members were successfully added';

    describe('when inviting an existing user to group by user ID', () => {
      const postData = {
        user_id: '1',
        email: '',
        access_level: '10',
        expires_at: undefined,
        format: 'json',
      };

      describe('when invites are sent successfully', () => {
        beforeEach(() => {
          wrapper = createComponent({ newUsersToInvite: '1' });

          wrapper.vm.$toast = { show: jest.fn() };
          jest.spyOn(Api, 'inviteGroupMember').mockResolvedValue({ data: postData });

          findInviteButton().vm.$emit('click');
        });

        it('calls Api inviteGroupMember with the correct params', () => {
          expect(Api.inviteGroupMember).toHaveBeenCalledWith(id, postData);
        });

        it('displays the successful toastMessage', () => {
          expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(
            toastMessageSuccessful,
            wrapper.vm.toastOptions,
          );
        });
      });

      describe('when the invite received an api error message', () => {
        beforeEach(() => {
          wrapper = createComponent({ newUsersToInvite: '123' });

          wrapper.vm.$toast = { show: jest.fn() };
          jest
            .spyOn(Api, 'inviteGroupMember')
            .mockRejectedValue({ response: { data: { message: apiErrorMessage } } });

          findInviteButton().vm.$emit('click');
        });

        it('displays the apiErrorMessage in the toastMessage', () => {
          expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(
            apiErrorMessage,
            wrapper.vm.toastOptions,
          );
        });
      });

      describe('when any invite failed for any other reason', () => {
        beforeEach(() => {
          wrapper = createComponent({ newUsersToInvite: '123,456' });

          wrapper.vm.$toast = { show: jest.fn() };
          jest
            .spyOn(Api, 'inviteGroupMember')
            .mockRejectedValue({ response: { data: { success: false } } });

          findInviteButton().vm.$emit('click');
        });

        it('displays the generic error toastMessage', () => {
          expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(
            genericErrorMessage,
            wrapper.vm.toastOptions,
          );
        });
      });
    });

    describe('when inviting a new user by email address', () => {
      const postData = {
        access_level: '10',
        expires_at: undefined,
        email: 'email@example.com',
        user_id: '',
        format: 'json',
      };

      describe('when invites are sent successfully', () => {
        beforeEach(() => {
          wrapper = createComponent({ newUsersToInvite: 'email@example.com' });

          wrapper.vm.$toast = { show: jest.fn() };
          jest.spyOn(Api, 'inviteNonMemberToGroup').mockResolvedValue({ data: postData });

          findInviteButton().vm.$emit('click');
        });

        it('calls Api inviteNonMemberToGroup with the correct params', () => {
          expect(Api.inviteNonMemberToGroup).toHaveBeenCalledWith(id, postData);
        });

        it('displays the successful toastMessage', () => {
          expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(
            toastMessageSuccessful,
            wrapper.vm.toastOptions,
          );
        });
      });

      describe('when any invite failed for any reason', () => {
        beforeEach(() => {
          wrapper = createComponent({ newUsersToInvite: '123,456' });

          wrapper.vm.$toast = { show: jest.fn() };
          jest
            .spyOn(Api, 'inviteGroupMember')
            .mockRejectedValue({ response: { data: { success: false } } });

          findInviteButton().vm.$emit('click');
        });

        it('displays the generic error toastMessage', () => {
          expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(
            genericErrorMessage,
            wrapper.vm.toastOptions,
          );
        });
      });
    });

    describe('when inviting members and non-members in same click', () => {
      const postData = {
        user_id: '1',
        access_level: '10',
        expires_at: undefined,
        email: 'email@example.com',
        format: 'json',
      };

      describe('when invites are sent successfully', () => {
        beforeEach(() => {
          wrapper = createComponent({ newUsersToInvite: 'email@example.com,1' });

          wrapper.vm.$toast = { show: jest.fn() };
          jest.spyOn(Api, 'inviteNonMemberToGroup').mockResolvedValue({ data: postData });
          jest.spyOn(Api, 'inviteGroupMember').mockResolvedValue({ data: postData });

          findInviteButton().vm.$emit('click');
        });

        it('calls Api inviteNonMemberToGroup with the correct params', () => {
          expect(Api.inviteNonMemberToGroup).toHaveBeenCalledWith(id, postData);
        });

        it('calls Api inviteGroupMember with the correct params', () => {
          expect(Api.inviteGroupMember).toHaveBeenCalledWith(id, postData);
        });

        it('displays the successful toastMessage', () => {
          expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(
            toastMessageSuccessful,
            wrapper.vm.toastOptions,
          );
        });
      });

      describe('when any invite failed for any reason', () => {
        beforeEach(() => {
          wrapper = createComponent({ newUsersToInvite: '0,email@example.com' });

          wrapper.vm.$toast = { show: jest.fn() };

          jest
            .spyOn(Api, 'inviteNonMemberToGroup')
            .mockRejectedValue({ response: { data: { success: false } } });

          jest.spyOn(Api, 'inviteGroupMember').mockResolvedValue({ data: postData });

          findInviteButton().vm.$emit('click');
        });

        it('displays the generic error toastMessage', () => {
          expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(
            genericErrorMessage,
            wrapper.vm.toastOptions,
          );
        });
      });
    });
  });
});
