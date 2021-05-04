import { GlLink } from '@gitlab/ui';
import { mount } from '@vue/test-utils';

import BranchDetails from 'ee/compliance_dashboard/components/merge_requests/branch_details.vue';

describe('BranchDetails component', () => {
  let wrapper;

  // The truncate component adds left-to-right marks into the text that we have to remove
  const getText = () => wrapper.text().replace(/\u200E/gi, '');
  const linkExists = (testId) => wrapper.find(`[data-testid="${testId}"]`).exists();

  const createComponent = ({ sourceUri = '', targetUri = '' } = {}) => {
    return mount(BranchDetails, {
      propsData: {
        sourceBranch: {
          name: 'feature',
          uri: sourceUri,
        },
        targetBranch: {
          name: 'main',
          uri: targetUri,
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with branch details', () => {
    describe('and no branch URIs', () => {
      beforeEach(() => {
        wrapper = createComponent();
      });

      it('has no links', () => {
        expect(wrapper.find(GlLink).exists()).toBe(false);
      });

      it('has the correct text', () => {
        expect(getText()).toEqual('feature into main');
      });
    });

    describe('and one branch URI', () => {
      beforeEach(() => {
        wrapper = createComponent({ targetUri: '/main-uri' });
      });

      it('has one link', () => {
        expect(wrapper.findAll(GlLink)).toHaveLength(1);
      });

      it('has a link to the target branch', () => {
        expect(linkExists('target-branch-uri')).toBe(true);
      });

      it('has the correct text', () => {
        expect(getText()).toEqual('feature into main');
      });
    });

    describe('and both branch URIs', () => {
      beforeEach(() => {
        wrapper = createComponent({ sourceUri: '/feature-uri', targetUri: '/main-uri' });
      });

      it('has two links', () => {
        expect(wrapper.findAll(GlLink)).toHaveLength(2);
      });

      it('has a link to the source branch', () => {
        expect(linkExists('source-branch-uri')).toBe(true);
      });

      it('has a link to the target branch', () => {
        expect(linkExists('target-branch-uri')).toBe(true);
      });

      it('has the correct text', () => {
        expect(getText()).toEqual('feature into main');
      });
    });
  });
});
