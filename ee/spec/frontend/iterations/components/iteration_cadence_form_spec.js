import { GlForm, GlFormGroup } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import { ApolloMutation } from 'vue-apollo';
import IterationCadenceForm from 'ee/iterations/components/iteration_cadence_form.vue';
import createCadence from 'ee/iterations/queries/create_cadence.mutation.graphql';
import { TEST_HOST } from 'helpers/test_constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { visitUrl } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility');

describe('Iteration cadence form', () => {
  let wrapper;
  const groupPath = 'gitlab-org';
  const id = 72;
  const cadence = {
    id: `gid://gitlab/Iteration/${id}`,
    title: 'An iteration',
    description: 'The words',
    startDate: '2020-06-28',
    dueDate: '2020-07-05',
  };

  const createMutationSuccess = {
    data: { iterationCadenceCreate: { cadence, errors: [] } },
  };
  const createMutationFailure = {
    data: {
      iterationCadenceCreate: { cadence, errors: ['alas, your data is unchanged'] },
    },
  };
  const defaultProps = { groupPath, cadencesListPath: TEST_HOST };

  function createComponent({ mutationResult = createMutationSuccess, props = defaultProps } = {}) {
    wrapper = extendedWrapper(
      shallowMount(IterationCadenceForm, {
        propsData: props,
        stubs: {
          ApolloMutation,
          GlFormGroup,
        },
        mocks: {
          $apollo: {
            mutate: jest.fn().mockResolvedValue(mutationResult),
          },
        },
      }),
    );
  }

  afterEach(() => {
    wrapper.destroy();
  });

  const findTitle = () => wrapper.find('#cadence-title');
  const findStartDate = () => wrapper.find('#cadence-start-date');
  const findIterationsInAdvance = () => wrapper.find('#cadence-schedule-future-iterations');
  const findDuration = () => wrapper.find('#cadence-duration');
  const findSaveButton = () => wrapper.findByTestId('save-cadence');
  const findCancelButton = () => wrapper.findByTestId('cancel-create-cadence');
  const clickSave = () => findSaveButton().vm.$emit('click');
  const clickCancel = () => findCancelButton().vm.$emit('click');

  it('renders a form', () => {
    createComponent();
    expect(wrapper.find(GlForm).exists()).toBe(true);
  });

  describe('Create cadence', () => {
    beforeEach(() => {
      createComponent();
    });

    it('cancel button links to list page', () => {
      clickCancel();

      expect(visitUrl).toHaveBeenCalledWith(TEST_HOST);
    });

    describe('required fields', () => {
      it('requires title', () => {
        clickSave();

        console.log(wrapper.html());

        expect(wrapper.findComponent(GlFormGroup)).toHaveText('This field is required');
      });
    });

    describe('save', () => {
      it('triggers mutation with form data', () => {
        const title = 'Iteration 5';
        const startDate = '2020-05-05';
        const durationInWeeks = 2;
        const iterationsInAdvance = 6;

        findTitle().vm.$emit('input', title);
        findStartDate().vm.$emit('input', startDate);
        findDuration().vm.$emit('input', durationInWeeks);
        findIterationsInAdvance().vm.$emit('input', iterationsInAdvance);

        clickSave();

        expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
          mutation: createCadence,
          variables: {
            input: {
              groupPath,
              title,
              automatic: true,
              startDate,
              durationInWeeks,
              active: true,
            },
            iterationsInAdvance,
          },
        });
      });

      it('redirects to Iteration page on success', async () => {
        createComponent();

        const title = 'Iteration 5';
        const startDate = '2020-05-05';
        const durationInWeeks = 2;
        const iterationsInAdvance = 6;

        findTitle().vm.$emit('input', title);
        findStartDate().vm.$emit('input', startDate);
        findDuration().vm.$emit('input', durationInWeeks);
        findIterationsInAdvance().vm.$emit('input', iterationsInAdvance);

        clickSave();

        await nextTick();

        expect(findSaveButton().props('loading')).toBe(true);
        expect(visitUrl).toHaveBeenCalled();
      });

      it('loading=false on error', () => {
        createComponent({ mutationResult: createMutationFailure });

        clickSave();

        return waitForPromises().then(() => {
          expect(findSaveButton().props('loading')).toBe(false);
        });
      });
    });
  });
});
