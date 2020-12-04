export async function awaitApolloDomMock(wrapper, jest) {
  await wrapper.vm.$nextTick(); // kick off the DOM update
  await jest.runOnlyPendingTimers(); // kick off the mocked GQL stuff (promises)
  await wrapper.vm.$nextTick(); // kick off the DOM update for flash
}
