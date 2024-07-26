let debounceTimer;

function debounce(callback, timeMs) {
  window.clearTimeout(debounceTimer);
  debounceTimer = window.setTimeout(callback, timeMs);
}

export { debounce };
