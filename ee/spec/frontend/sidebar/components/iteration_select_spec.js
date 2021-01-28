import { GlDropdown, GlDropdownItem, GlSearchBoxByType } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import IterationSelect from 'ee/sidebar/components/iteration_select.vue';
import { iterationSelectTextMap } from 'ee/sidebar/constants';
import setIterationOnIssue from 'ee/sidebar/queries/set_iteration_on_issue.mutation.graphql';
import { deprecatedCreateFlash as createFlash } from '~/flash';

jest.mock('~/flash');

describe('IterationSelect', () => {
  let wrapper;
  let eventSpy;

  const promiseData = { issueSetIteration: { issue: { iteration: { id: '123' } } } };
  const firstErrorMsg = 'first error';
  const promiseWithErrors = {
    ...promiseData,
    issueSetIteration: { ...promiseData.issueSetIteration, errors: [firstErrorMsg] },
  };
  const mutationSuccess = () => jest.fn().mockResolvedValue({ data: promiseData });
  const mutationError = () => jest.fn().mockRejectedValue();
  const mutationSuccessWithErrors = () => jest.fn().mockResolvedValue({ data: promiseWithErrors });

  const createComponent = ({
    data = {},
    mutationPromise = mutationSuccess,
    props = {},
    stubs = {},
  } = {}) => {
    wrapper = shallowMount(IterationSelect, {
      data() {
        return data;
      },
      propsData: {
        groupPath: '',
        projectPath: '',
        issueIid: '',
        dropdownOpen: true,
        ...props,
      },
      mocks: {
        $apollo: {
          mutate: mutationPromise(),
        },
      },
      stubs,
    });
  };

  const setupEventSpy = () => {
    eventSpy = jest.spyOn(wrapper.vm, '$emit');
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when a user can edit', () => {
    it('focuses on the input and shows the dropdown', async () => {
      createComponent({
        props: { dropdownOpen: false },
      });

      const setFocus = jest.spyOn(wrapper.vm, 'setFocus').mockImplementation();
      const showDropdown = jest.spyOn(wrapper.vm, 'showDropdown').mockImplementation();

      wrapper.setProps({ dropdownOpen: true });

      await wrapper.vm.$nextTick();

      wrapper.find(GlDropdown).vm.$emit('shown');

      expect(setFocus).toHaveBeenCalled();
      expect(showDropdown).toHaveBeenCalled();
    });

    describe('when user is editing', () => {
      describe('when rendering the dropdown', () => {
        it('shows GlDropdown', () => {
          createComponent();

          expect(wrapper.find(GlDropdown).isVisible()).toBe(true);
        });

        describe('GlDropdownItem with the right title and id', () => {
          const id = 'id';
          const title = 'title';

          beforeEach(() => {
            createComponent({
              data: { iterations: [{ id, title }], currentIteration: { id, title } },
            });
          });

          it('renders title $title', () => {
            expect(
              wrapper
                .findAll(GlDropdownItem)
                .filter((w) => w.text() === title)
                .at(0)
                .text(),
            ).toBe(title);
          });

          it('checks the correct dropdown item', () => {
            expect(
              wrapper
                .findAll(GlDropdownItem)
                .filter((w) => w.props('isChecked') === true)
                .at(0)
                .text(),
            ).toBe(title);
          });
        });

        describe('when no data is assigned', () => {
          beforeEach(() => {
            createComponent();
          });

          it('finds GlDropdownItem with "No iteration"', () => {
            expect(wrapper.find(GlDropdownItem).text()).toBe('No iteration');
          });

          it('"No iteration" is checked', () => {
            expect(wrapper.find(GlDropdownItem).props('isChecked')).toBe(true);
          });
        });

        describe('when clicking on dropdown item', () => {
          describe('when currentIteration is equal to iteration id', () => {
            it('does not call setIssueIteration mutation', () => {
              createComponent({
                data: {
                  iterations: [{ id: 'id', title: 'title' }],
                  currentIteration: { id: 'id', title: 'title' },
                },
              });

              wrapper
                .findAll(GlDropdownItem)
                .filter((w) => w.text() === 'title')
                .at(0)
                .vm.$emit('click');

              expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(0);
            });
          });

          describe('when currentIteration is not equal to iteration id', () => {
            describe('when success', () => {
              beforeEach(() => {
                createComponent({
                  data: {
                    iterations: [
                      { id: 'id', title: 'title' },
                      { id: '123', title: '123' },
                    ],
                    currentIteration: '123',
                  },
                });
                setupEventSpy();

                wrapper
                  .findAll(GlDropdownItem)
                  .filter((w) => w.text() === 'title')
                  .at(0)
                  .vm.$emit('click');
              });

              it('calls setIssueIteration mutation', () => {
                expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
                  mutation: setIterationOnIssue,
                  variables: { projectPath: '', iterationId: 'id', iid: '' },
                });
              });

              it('sets the value returned from the mutation to currentIteration', async () => {
                await wrapper.vm.$nextTick();
                expect(wrapper.vm.currentIteration).toBe('123');
              });

              it('should emit "dropdownClose" event after the mutation request is finished', () => {
                expect(eventSpy).toHaveBeenCalledWith('dropdownClose');
                expect(eventSpy).toHaveBeenCalledTimes(1);
              });
            });

            describe('when error', () => {
              const bootstrapComponent = (mutationResp) => {
                createComponent({
                  data: {
                    iterations: [
                      { id: '123', title: '123' },
                      { id: 'id', title: 'title' },
                    ],
                    currentIteration: '123',
                  },
                  mutationPromise: mutationResp,
                });
                setupEventSpy();
              };

              describe.each`
                description                 | mutationResp                 | expectedMsg
                ${'top-level error'}        | ${mutationError}             | ${iterationSelectTextMap.iterationSelectFail}
                ${'user-recoverable error'} | ${mutationSuccessWithErrors} | ${firstErrorMsg}
              `(`$description`, ({ mutationResp, expectedMsg }) => {
                beforeEach(() => {
                  bootstrapComponent(mutationResp);

                  wrapper
                    .findAll(GlDropdownItem)
                    .filter((w) => w.text() === 'title')
                    .at(0)
                    .vm.$emit('click');
                });

                it('calls createFlash with $expectedMsg', async () => {
                  await wrapper.vm.$nextTick();
                  expect(createFlash).toHaveBeenCalledWith(expectedMsg);
                });

                it('should emit "dropdownClose" event after the mutation request is finished', () => {
                  expect(eventSpy).toHaveBeenCalledWith('dropdownClose');
                  expect(eventSpy).toHaveBeenCalledTimes(1);
                });
              });
            });
          });
        });
      });

      describe('when a user is searching', () => {
        beforeEach(() => {
          createComponent({ stubs: { GlSearchBoxByType } });
        });

        it('sets the search term', async () => {
          wrapper.find(GlSearchBoxByType).vm.$emit('input', 'testing');

          await wrapper.vm.$nextTick();
          expect(wrapper.vm.searchTerm).toBe('testing');
        });
      });
    });

    describe('apollo schema', () => {
      describe('iterations', () => {
        beforeEach(() => {
          createComponent();
        });

        describe('when iterations is passed the wrong data object', () => {
          it.each([
            [{}, []],
            [{ group: {} }, []],
            [{ group: { iterations: {} } }, []],
            [{ group: { iterations: { nodes: ['nodes'] } } }, ['nodes']],
          ])('when %j as an argument it returns %j', (data, value) => {
            const { update } = wrapper.vm.$options.apollo.iterations;

            expect(update(data)).toEqual(value);
          });
        });

        it('contains debounce', () => {
          const { debounce } = wrapper.vm.$options.apollo.iterations;

          expect(debounce).toBe(250);
        });

        it('returns the correct values based on the schema', () => {
          const { update } = wrapper.vm.$options.apollo.iterations;
          // needed to access this.$options in update
          const boundUpdate = update.bind(wrapper.vm);

          expect(boundUpdate({ group: { iterations: { nodes: [] } } })).toEqual([]);
        });
      });

      describe('currentIteration', () => {
        let boundUpdate;
        let boundResult;
        const fakeIteration = { id: '123' };
        const fakeData = { project: { issue: { iteration: fakeIteration } } };

        beforeEach(() => {
          createComponent();
          setupEventSpy();

          const { update, result } = wrapper.vm.$options.apollo.currentIteration;

          boundUpdate = update.bind(wrapper.vm);
          boundResult = result.bind(wrapper.vm);
        });

        it('should emit "iterationUpdate" event on update', async () => {
          boundResult({ data: fakeData });

          expect(eventSpy).toHaveBeenCalledWith('iterationUpdate', fakeIteration);
        });

        describe('when passes an object that doesnt contain the correct values', () => {
          it.each([
            [{}, null],
            [{ project: { issue: {} } }, null],
            [{ project: { issue: { iteration: {} } } }, null],
          ])('when %j as an argument it returns %j', (data, value) => {
            expect(boundUpdate(data)).toEqual(value);
          });
        });

        describe('when iteration has an id', () => {
          it('returns the id', () => {
            expect(boundUpdate(fakeData)).toEqual(fakeIteration);
          });
        });
      });
    });
  });
});
