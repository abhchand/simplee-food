import { setFlashError } from './flash';

function copyToClipboard(text) {
  if (location.protocol !== 'https:') {
    setFlashError('https is required to copy to clipboard');
    return false;
  }
  if (!navigator.clipboard) {
    setFlashError('copying to clipboard is not supported in your browser.');
    return false;
  }

  navigator.clipboard
    .writeText(text)
    .catch(() => setFlashError('could not copy to clipboard'));

  return true;
}

export { copyToClipboard };
