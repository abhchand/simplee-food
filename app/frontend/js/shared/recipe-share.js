import { copyToClipboard } from './clipboard';

function onRecipeShare(event) {
  const clicked = event.currentTarget;
  const item = clicked.closest('.shareable');

  // Copy to clipboard
  const url = window.location.origin + '/recipes/' + item.dataset.name;
  if (!copyToClipboard(url)) {
    return;
  }

  // Create tool tip
  const span = document.createElement('span');
  span.setAttribute('class', 'floating-tooltip');
  span.textContent = 'copied!';
  clicked.appendChild(span);

  setTimeout(() => clicked.removeChild(clicked.lastChild), 1000);
}

export { onRecipeShare };
