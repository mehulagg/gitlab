import { GlDropdown, GlDropdownItem, GlButton, GlLink, GlSearchBoxByType } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import IterationSelect from 'ee/sidebar/components/iteration_select.vue';
import { iterationSelectTextMap } from 'ee/sidebar/constants';
import setIterationOnIssue from 'ee/sidebar/queries/set_iteration_on_issue.mutation.graphql';
import { deprecatedCreateFlash as createFlash } from '~/flash';

jest.mock('~/flash');

describe('IterationSelect', () => {
  let wrapper;
  const promiseData = { issueSetIteration: { issue: { iteration: { id: '123' } } } };
  const firstErrorMsg = 'first error';
  const promiseWithErrors = {
    ...promiseData,
    issueSetIteration: { ...promiseData.issueSetIteration, errors: [firstErrorMsg] },
  };
  const mutationSuccess = () => jest.fn().mockResolvedValue({ data: promiseData });
  const mutationError = () => jest.fn().mockRejectedValue();
  const mutationSuccessWithErrors = () => jest.fn().mockResolvedValue({ data: promiseWithErrors });
  const toggleDropdown = (spy = () => {}) =>
    wrapper.find(GlButton).vm.$emit('click', { stopPropagation: spy });

  const createComponent = ({
    data = {},
    mutationPromise = mutationSuccess,
    props = { canEdit: true },
  }) => {
    wrapper = shallowMount(IterationSelect, {
      data() {
        return data;
      },
      propsData: {
        ...props,
        groupPath: '',
        projectPath: '',
        issueIid: '',
      },
      mocks: {
        $options: {
          noIterationItem: [],
        },
        $apollo: {
          mutate: mutationPromise(),
        },
      },
      stubs: {
        GlSearchBoxByType,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when not editing', () => {
    it('shows the current iteration', () => {
      createComponent({
        data: { iterations: [{ id: 'id', title: 'title' }], currentIteration: 'id' },
      });

      expect(wrapper.find('[data-testid="select-iteration"]').text()).toBe('title');
    });

    it('links to the current iteration', () => {
      createComponent({
        data: {
          iterations: [{ id: 'id', title: 'title', webUrl: 'webUrl' }],
          currentIteration: 'id',
        },
      });

      expect(wrapper.find(GlLink).attributes().href).toBe('webUrl');
    });
  });

  describe('when a user cannot edit', () => {
    it('cannot find the edit button', () => {
      createComponent({ props: { canEdit: false } });

      expect(wrapper.find(GlButton).exists()).toBe(false);
    });
  });

  describe('when a user can edit', () => {
    it('opens the dropdown on click of the edit button', async () => {
      createComponent({ props: { canEdit: true } });

      expect(wrapper.find(GlDropdown).isVisible()).toBe(false);

      toggleDropdown();

      await wrapper.vm.$nextTick();
      expect(wrapper.find(GlDropdown).isVisible()).toBe(true);
    });

    it('focuses on the input', async () => {
      createComponent({ props: { canEdit: true } });

      const spy = jest.spyOn(wrapper.vm.$refs.search, 'focusInput');

      toggleDropdown();

      await wrapper.vm.$nextTick();
      expect(spy).toHaveBeenCalled();
    });

    it('stops propagation of the click event to avoid opening milestone dropdown', async () => {
      const spy = jest.fn();
      createComponent({ props: { canEdit: true } });

      expect(wrapper.find(GlDropdown).isVisible()).toBe(false);

      toggleDropdown(spy);

      await wrapper.vm.$nextTick();
      expect(spy).toHaveBeenCalledTimes(1);
    });

    describe('when user is editing', () => {
      describe('when rendering the dropdown', () => {
        it('shows GlDropdown', () => {
          createComponent({ props: { canEdit: true }, data: { editing: true } });

          expect(wrapper.find(GlDropdown).isVisible()).toBe(true);
        });

        describe('GlDropdownItem with the right title and id', () => {
          const id = 'id';
          const title = 'title';

          beforeEach(() => {
            createComponent({ data: { iterations: [{ id, title }], currentIteration: id } });
          });

          it('renders title $title', () => {
            expect(
              wrapper
                .findAll(GlDropdownItem)
                .filter(w => w.text() === title)
                .at(0)
                .text(),
            ).toBe(title);
          });

          it('checks the correct dropdown item', () => {
            expect(
              wrapper
                .findAll(GlDropdownItem)
                .filter(w => w.props('isChecked') === true)
                .at(0)
                .text(),
            ).toBe(title);
          });
        });

        describe('when no data is assigned', () => {
          beforeEach(() => {
            createComponent({});
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
                data: { iterations: [{ id: 'id', title: 'title' }], currentIteration: 'id' },
              });

              wrapper
                .findAll(GlDropdownItem)
                .filter(w => w.text() === 'title')
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
                    iterations: [{ id: 'id', title: 'title' }, { id: '123', title: '123' }],
                    currentIteration: '123',
                  },
                });

                wrapper
                  .findAll(GlDropdownItem)
                  .filter(w => w.text() === 'title')
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
            });

            describe('when error', () => {
              const bootstrapComponent = mutationResp => {
                createComponent({
                  data: {
                    iterations: [{ id: '123', title: '123' }, { id: 'id', title: 'title' }],
                    currentIteration: '123',
                  },
                  mutationPromise: mutationResp,
                });
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
                    .filter(w => w.text() === 'title')
                    .at(0)
                    .vm.$emit('click');
                });

                it('calls createFlash with $expectedMsg', async () => {
                  await wrapper.vm.$nextTick();
                  expect(createFlash).toHaveBeenCalledWith(expectedMsg);
                });
              });
            });
          });
        });
      });

      describe('when a user is searching', () => {
        beforeEach(() => {
          createComponent({});
        });

        it('sets the search term', async () => {
          wrapper.find(GlSearchBoxByType).vm.$emit('input', 'testing');

          await wrapper.vm.$nextTick();
          expect(wrapper.vm.searchTerm).toBe('testing');
        });
      });

      describe('when the user off clicks', () => {
        describe('when the dropdown is open', () => {
          beforeEach(async () => {
            createComponent({});

            toggleDropdown();

            await wrapper.vm.$nextTick();
          });

          it('closes the dropdown', async () => {
            expect(wrapper.find(GlDropdown).isVisible()).toBe(true);

            toggleDropdown();

            await wrapper.vm.$nextTick();
            expect(wrapper.find(GlDropdown).isVisible()).toBe(false);
          });
        });
      });
    });

    describe('apollo schema', () => {
      describe('iterations', () => {
        describe('when iterations is passed the wrong data object', () => {
          beforeEach(() => {
            createComponent({});
          });

          it.each([
            [{}, iterationSelectTextMap.noIterationItem],
            [{ group: {} }, iterationSelectTextMap.noIterationItem],
            [{ group: { iterations: {} } }, iterationSelectTextMap.noIterationItem],
            [
              { group: { iterations: { nodes: ['nodes'] } } },
              [...iterationSelectTextMap.noIterationItem, 'nodes'],
            ],
          ])('when %j as an argument it returns %j', (data, value) => {
            const { update } = wrapper.vm.$options.apollo.iterations;

            expect(update(data)).toEqual(value);
          });
        });

        it('contains debounce', () => {
          createComponent({});

          const { debounce } = wrapper.vm.$options.apollo.iterations;

          expect(debounce).toBe(250);
        });

        it('returns the correct values based on the schema', () => {
          createComponent({});

          const { update } = wrapper.vm.$options.apollo.iterations;
          // needed to access this.$options in update
          const boundUpdate = update.bind(wrapper.vm);

          expect(boundUpdate({ group: { iterations: { nodes: [] } } })).toEqual(
            iterationSelectTextMap.noIterationItem,
          );
        });
      });

      describe('currentIteration', () => {
        describe('when passes an object that doesnt contain the correct values', () => {
          beforeEach(() => {
            createComponent({});
          });

          it.each([
            [{}, undefined],
            [{ project: { issue: {} } }, undefined],
            [{ project: { issue: { iteration: {} } } }, undefined],
          ])('when %j as an argument it returns %j', (data, value) => {
            const { update } = wrapper.vm.$options.apollo.currentIteration;

            expect(update(data)).toBe(value);
          });
        });

        describe('when iteration has an id', () => {
          it('returns the id', () => {
            createComponent({});

            const { update } = wrapper.vm.$options.apollo.currentIteration;

            expect(update({ project: { issue: { iteration: { id: '123' } } } })).toEqual('123');
          });
        });
      });
    });
  });
});
