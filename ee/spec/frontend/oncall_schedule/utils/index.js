export async function awaitApolloDomMock(vm, jest) {
  await jest.runOnlyPendingTimers(); // kick off the mocked GQL stuff (promises)
  await vm.$nextTick(); // kick off the DOM update for flash
}
