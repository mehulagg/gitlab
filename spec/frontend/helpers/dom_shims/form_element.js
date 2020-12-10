// eslint-disable-next-line func-names
HTMLFormElement.prototype.submit = function() {
  this.dispatchEvent(new Event('submit'));
};
