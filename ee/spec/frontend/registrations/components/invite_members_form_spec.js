import { GlForm, GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import InviteMembers from 'ee/groups/components/invite_members.vue';
import InviteMembersForm from 'ee/registrations/components/invite_members_form.vue';

jest.mock('~/lib/utils/csrf', () => ({ token: 'mock-csrf-token' }));

describe('InviteMembersForm', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(InviteMembersForm, {
      provide: { endpoint: '_endpoint_' },
      propsData: {
        docsPath: '_docs_path_',
        emails: [],
      },
    });
  };

  const form = () => wrapper.find(GlForm);
  const submitButton = () => form().find(GlButton);
  const inviteMembers = () => form().find(InviteMembers);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('displays form with correct action and inputs', () => {
    expect(form().attributes('action')).toBe('_endpoint_');
    expect(form().find('input[name="authenticity_token"]').attributes('value')).toBe(
      'mock-csrf-token',
    );
  });

  it('includes the invite members component', () => {
    expect(inviteMembers().exists()).toBe(true);
    expect(inviteMembers().props('docsPath')).toBe('_docs_path_');
    expect(inviteMembers().props('emails')).toEqual([]);
    expect(inviteMembers().props('initialEmailInputs')).toBe(3);
    expect(inviteMembers().props('emailPlaceholderPrefix')).toBe('teammate');
    expect(inviteMembers().props('addAnotherText')).toBe('Invite another teammate');
    expect(inviteMembers().props('inputName')).toBe('emails[]');
  });

  it('has correct text on submit button', () => {
    expect(submitButton().text()).toBe('Send invitations');
  });
});
