export default function createStore() {
  const store = {
    state: {
      error: '',
    },
    /**
     * setErrorMessage sets the state's error value
     * @param {string} errorMessage
     */
    setErrorMessage(errorMessage) {
      this.state.error = errorMessage;
    },
  };

  return store;
}
