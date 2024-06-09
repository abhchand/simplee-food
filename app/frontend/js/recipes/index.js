import { copyToClipboard } from '../shared/clipboard';
import { fromHTML } from '../shared/html';

function onRecipeSearch(_event) {
  // Reset the page to the first each time we search
  renderRecipeList({ page: 1 });
}

function onRecipeShare(event) {
  const clicked = event.currentTarget;
  const item = clicked.closest('.recipe-item');

  // Copy to clipboard
  const url = window.location.origin + '/recipes/' + item.dataset.id;
  if (!copyToClipboard(url)) {
    return;
  }

  // Create tool tip
  const span = document.createElement('span');
  span.setAttribute('class', 'recipe-item--copied');
  span.textContent = 'copied!';
  clicked.appendChild(span);

  setTimeout(() => clicked.removeChild(clicked.lastChild), 1000);
}

function onRecipeSort(_event) {
  const curSelected = document.querySelector('button.selected');
  const newSelected = event.currentTarget;

  curSelected.classList.remove('selected');
  newSelected.classList.add('selected');

  // Reset the page to the first each time we change sorting
  renderRecipeList({ page: 1 });
}

function onPaginationNext() {
  // Don't worry about lower/upper bounds - the server gracefully handles this
  renderRecipeList({ page: getCurrentPage() + 1 });
}

function onPaginationPrev() {
  // Don't worry about lower/upper bounds - the server gracefully handles this
  renderRecipeList({ page: getCurrentPage() - 1 });
}

function renderRecipeList({ page }) {
  const params = new URLSearchParams({
    page: page || getCurrentPage(),
    search: getCurrentSearch(),
    sort_by: getCurrentSortBy()
  });

  const url = `/api/recipes?${params.toString()}`;

  fetch(url)
    .then((response) => response.json())
    .then(onSuccess)
    .catch(onFailure);
}

function onSuccess(json) {
  let curNode = document.getElementById('recipe-content');
  let newNode = fromHTML(json['html']);

  curNode.replaceWith(newNode);
}

function onFailure(_error) {
  curNode = document.getElementById('recipe-list');
  newNode = fromHTML('<span>oops, something went wrong!</span>');

  curNode.replaceWith(newNode);
}

function getCurrentPage() {
  return parseInt(
    document.getElementById('recipe-content').dataset.currentPage
  );
}

function getCurrentSearch() {
  return document.getElementById('recipe-search').value;
}

function getCurrentSortBy() {
  return document.querySelector('button.selected').dataset.id;
}

export {
  onPaginationNext,
  onPaginationPrev,
  onRecipeSearch,
  onRecipeShare,
  onRecipeSort
};
