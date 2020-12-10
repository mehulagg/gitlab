// eslint-disable-next-line func-names
HTMLFormElement.prototype.submit = jest.fn().mockImplementation(function() {
  this.dispatchEvent(new Event('submit'));
});
