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
    .then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP error - status: ${response.status}`);
      }
      return response.json();
    })
    .then((_data) => (window.location.href = '/recipes'))
    .catch((_error) => setFlashError('Unable to delete Recipe'));
}

export { onRecipeStepClick, onRecipeDelete };
