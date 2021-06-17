import { GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { mockTracking, unmockTracking } from 'helpers/tracking_helper';
import CiEditorHeader from '~/pipeline_editor/components/editor/ci_editor_header.vue';
import { pipelineEditorTrackingOptions } from '~/pipeline_editor/constants';

describe('CI Editor Header', () => {
  let wrapper;
  let trackingSpy = null;

  const createComponent = () => {
    wrapper = shallowMount(CiEditorHeader, {});
  };

  const findLinkBtn = () => wrapper.findComponent(GlButton);

  afterEach(() => {
    wrapper.destroy();
    unmockTracking();
  });

  describe('link button', () => {
    beforeEach(() => {
      createComponent();
      trackingSpy = mockTracking(undefined, wrapper.element, jest.spyOn);
    });

    it('finds the browse template button', () => {
      expect(findLinkBtn().exists()).toBe(true);
    });

    it('contains the link to the template repo', () => {
      expect(findLinkBtn().html()).toContain(
        'https://gitlab.com/gitlab-org/gitlab-foss/tree/master/lib/gitlab/ci/templates',
      );
    });

    it('has the external-link icon', () => {
      expect(findLinkBtn().props('icon')).toBe('external-link');
    });

    it('tracks the click on the browse button', async () => {
      const { label, actions } = pipelineEditorTrackingOptions;

      await findLinkBtn().vm.$emit('click');

      expect(trackingSpy).toHaveBeenCalledWith(undefined, actions.browse_templates, {
        label,
      });
    });
  });
});
