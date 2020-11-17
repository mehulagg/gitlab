import { GlAvatarLink, GlAvatar } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import MergeRequest from 'ee/compliance_dashboard/components/merge_requests/merge_request.vue';
import { createMergeRequest } from '../../mock_data';

describe('MergeRequest component', () => {
  let wrapper;

  const findAuthorAvatarLink = () => wrapper.find('.issuable-authored').find(GlAvatarLink);

  const createComponent = mergeRequest => {
    return shallowMount(MergeRequest, {
      propsData: {
        mergeRequest,
      },
      stubs: {
        CiIcon: {
          props: { status: Object },
          template: `<div class="ci-icon">{{ status.group }}</div>`,
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when there is a merge request', () => {
    const mergeRequest = createMergeRequest();

    beforeEach(() => {
      wrapper = createComponent(mergeRequest);
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders the title', () => {
      expect(wrapper.text()).toContain(mergeRequest.title);
    });

    it('renders the issuable reference', () => {
      expect(wrapper.text()).toContain(mergeRequest.issuable_reference);
    });

    it('renders the author avatar', () => {
      expect(
        findAuthorAvatarLink()
          .find(GlAvatar)
          .exists(),
      ).toEqual(true);
    });

    it('renders the author name', () => {
      expect(findAuthorAvatarLink().text()).toEqual(mergeRequest.author.name);
    });
  });
});
