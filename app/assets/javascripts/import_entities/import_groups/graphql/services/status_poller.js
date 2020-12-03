export class StatusPoller {
  constructor({ client, interval }) {
    this.client = client;
    this.isActive = false;
    this.intervalId = null;
  }

  startPolling() {
    if (this.isActive) {
      return;
    }
  }

  stopPolling() {
    clearInterval(this.intervalId);
  }
}
