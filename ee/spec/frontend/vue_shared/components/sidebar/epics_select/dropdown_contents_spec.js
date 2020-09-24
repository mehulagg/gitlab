import { shallowMount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';

import DropdownContents from 'ee/vue_shared/components/sidebar/epics_select/dropdown_contents.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

import { mockEpic1, mockEpic2, mockEpics, noneEpic } from '../mock_data';

const epics = mockEpics.map(epic => convertObjectPropsToCamelCase(epic));

describe('EpicsSelect', () => {
  describe('DropdownContents', () => {
    let wrapper;

    beforeEach(() => {
      wrapper = shallowMount(DropdownContents, {
        propsData: {
          epics,
          selectedEpic: mockEpic1,
        },
      });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    describe('computed', () => {
      describe('isNoEpic', () => {
        it('should return true when `selectedEpic` is of type `No Epic`', done => {
          wrapper.setProps({
            selectedEpic: noneEpic,
          });

          wrapper.vm.$nextTick(() => {
            expect(wrapper.vm.isNoEpic).toBe(true);
            done();
          });
        });

        it('should return false when `selectedEpic` is an epic', () => {
          expect(wrapper.vm.isNoEpic).toBe(false);
        });
      });
    });

    describe('methods', () => {
      describe('isSelected', () => {
        it('should return true when passed `epic` param ID is same as `selectedEpic` prop', () => {
          expect(wrapper.vm.isSelected(mockEpic1)).toBe(true);
        });

        it('should return false when passed `epic` param ID is different from `selectedEpic` prop', () => {
          expect(wrapper.vm.isSelected(mockEpic2)).toBe(false);
        });
      });

      describe('handleItemClick', () => {
        it('should emit `onItemSelect` event with `epic` param when passed `epic` param is different from already selected epic', () => {
          jest.spyOn(wrapper.vm, '$emit');

          wrapper.vm.handleItemClick(mockEpic2);

          expect(wrapper.vm.$emit).toHaveBeenCalledWith('onItemSelect', mockEpic2);
        });

        it('should emit `onItemSelect` event with `No Epic` param when passed `epic` param is same as already selected epic', () => {
          jest.spyOn(wrapper.vm, '$emit');

          wrapper.vm.handleItemClick(mockEpic1);

          expect(wrapper.vm.$emit).toHaveBeenCalledWith('onItemSelect', noneEpic);
        });
      });
    });

    describe('template', () => {
      it('should render container element', () => {
        expect(wrapper.classes()).toContain('dropdown-content');
      });

      it('should render `No Epic` as first item within list', () => {
        const noneEl = wrapper.find('ul > li');

        expect(noneEl.attributes('data-epic-id')).toBe('None');
        expect(noneEl.find(GlLink).exists()).toBe(true);
        expect(noneEl.find(GlLink).text()).toBe('No Epic');
      });

      it('should render epics list for all provided epics', () => {
        const epicsEl = wrapper.findAll('ul > li');

        expect(epicsEl).toHaveLength(epics.length + 2); // includes divider & No Epic` <li>.
        expect(epicsEl.at(1).classes()).toContain('divider');
        expect(
          epicsEl
            .at(2)
            .find(GlLink)
            .text(),
        ).toBe(epics[0].title);
        expect(
          epicsEl
            .at(3)
            .find(GlLink)
            .text(),
        ).toBe(epics[1].title);
        expect(
          epicsEl
            .at(2)
            .find(GlLink)
            .classes(),
        ).toContain('is-active');
      });

      it('should render string "No matches found" when `epics` array is empty', () => {
        wrapper.setProps({
          epics: [],
        });

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.text()).toContain('No matches found');
        });
      });
    });
  });
});
