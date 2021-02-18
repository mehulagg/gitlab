import { within, fireEvent } from '@testing-library/dom';
import { mount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import ProjectsField from '~/access_tokens/components/projects_field.vue';
import ProjectsTokenSelector from '~/access_tokens/components/projects_token_selector.vue';

describe('ProjectsField', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = extendedWrapper(mount(ProjectsField));
  };

  const queryByLabelText = (text) => within(wrapper.element).queryByLabelText(text);
  const queryByText = (text) => within(wrapper.element).queryByText(text);
  const findProjectsTokenSelector = () => wrapper.findComponent(ProjectsTokenSelector);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders label and sub-label', () => {
    expect(queryByText('Projects')).not.toBe(null);
    expect(queryByText('Set access permissions for this token.')).not.toBe(null);
  });

  it('renders "All projects" radio selected by default', () => {
    const allProjectsRadio = queryByLabelText('All projects');

    expect(allProjectsRadio).not.toBe(null);
    expect(allProjectsRadio.checked).toBe(true);
  });

  it('renders "Selected projects" radio unchecked by default', () => {
    const selectedProjectsRadio = queryByLabelText('Selected projects');

    expect(selectedProjectsRadio).not.toBe(null);
    expect(selectedProjectsRadio.checked).toBe(false);
  });

  it('renders `projects-token-selector` component', () => {
    expect(findProjectsTokenSelector().exists()).toBe(true);
  });

  describe('when `projects-token-selector` is focused', () => {
    beforeEach(() => {
      findProjectsTokenSelector().vm.$emit('focus');
    });

    it('auto selects the "Selected projects" radio', () => {
      expect(queryByLabelText('Selected projects').checked).toBe(true);
    });

    describe('when `projects-token-selector` is changed', () => {
      beforeEach(() => {
        findProjectsTokenSelector().vm.$emit('input', [
          {
            id: 1,
          },
          {
            id: 2,
          },
        ]);
      });

      it('updates the hidden input value to a comma separated list of project IDs', () => {
        expect(wrapper.find('input[type="hidden"]').attributes('value')).toBe('1,2');
      });

      describe('when radio is changed back to "All projects"', () => {
        beforeEach(() => {
          fireEvent.click(queryByLabelText('All projects'));
        });

        it('removes the hidden input value', () => {
          expect(wrapper.find('input[type="hidden"]').attributes('value')).toBe('');
        });
      });
    });
  });
});
