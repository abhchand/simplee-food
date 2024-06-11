import { setFlashError } from '../shared/flash';

function onRecipeStepClick(event) {
  const el = event.currentTarget;

  if (el.classList.contains('selected')) {
    el.classList.remove('selected');
  } else {
    el.classList.add('selected');
  }
}

function onRecipeDelete(url) {
  if (!confirm('Are you sure you want to delete this recipe?')) {
    return;
  }

  fetch(url, { method: 'DELETE' })
    .then(() => (window.location.href = '/recipes'))
    .catch(() => setFlashError('Unable to delete Recipe'));
}

export { onRecipeStepClick, onRecipeDelete };
