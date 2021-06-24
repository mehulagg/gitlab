import { GlDropdownItem } from '@gitlab/ui';

export function renderTotalTime(selector, element, totalTime = {}) {
  const { days, hours, mins, seconds } = totalTime;
  if (days) {
    expect(element.find(selector).text()).toContain(days);
  } else if (hours) {
    expect(element.find(selector).text()).toContain(hours);
  } else if (mins) {
    expect(element.find(selector).text()).toContain(mins);
  } else if (seconds) {
    expect(element.find(selector).text()).toContain(seconds);
  } else {
    // events that havent started have totalTime = {}
    expect(element.find(selector).text()).toEqual('--');
  }
}

export const findDropdownItems = (wrapper) => wrapper.findAllComponents(GlDropdownItem);

export const findDropdownItemText = (wrapper) =>
  findDropdownItems(wrapper).wrappers.map((w) => w.text());

export default {
  renderTotalTime,
  findDropdownItems,
  findDropdownItemText,
};
