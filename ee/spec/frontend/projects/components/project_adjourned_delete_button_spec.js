import { shallowMount } from '@vue/test-utils';
import ProjectAdjournedDeleteButton from 'ee/projects/components/project_adjourned_delete_button.vue';
import SharedDeleteButton from '~/projects/components/shared/delete_button.vue';

jest.mock('lodash/uniqueId', () => () => 'fakeUniqueId');

describe('Project remove modal', () => {
  let wrapper;

  const findSharedDeleteButton = () => wrapper.find(SharedDeleteButton);

  const defaultProps = {
    adjournedRemovalDate: '2020-12-12',
    confirmPhrase: 'foo',
    formPath: 'some/path',
    recoveryHelpPath: 'recovery/help/path',
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(ProjectAdjournedDeleteButton, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      stubs: {
        SharedDeleteButton,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('initialized', () => {
    beforeEach(() => {
      createComponent();
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('passes confirmPhrase and formPath props to the shared delete button', () => {
      expect(findSharedDeleteButton().props()).toEqual({
        confirmPhrase: defaultProps.confirmPhrase,
        formPath: defaultProps.formPath,
      });
    });
  });
});
