import { fromHTML } from '../shared/html';

function onRecipeSearch(_event) {
  // Add or remove the "--touched" class as needed, based on whether
  const input = document.querySelector('.recipes-index__search-input');
  const touchedClass = 'recipes-index__search-input--touched';

  if (input.value && !input.classList.contains(touchedClass)) {
    input.classList.add(touchedClass);
  }
  if (!input.value && input.classList.contains(touchedClass)) {
    input.classList.remove(touchedClass);
  }

  // Update the recipe list, but also reset the page to the first page
  // each time we search
  renderRecipeList({ page: 1 });
}

function onRecipeSearchClear(_event) {
  const input = document.querySelector('.recipes-index__search-input');

  input.value = '';
  input.focus();
  input.classList.remove('recipes-index__search-input--touched');

  // Trigger a search to update results
  onRecipeSearch();
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
    sort_by: getCurrentSortBy(),
    tag: getCurrentTag()
  });

  const url = `/api/recipes?${params.toString()}`;

  fetch(url)
    .then((response) => response.json())
    .then(onSuccess)
    .catch(onFailure);
}

function onSuccess(json) {
  let curNode = document.querySelector('.recipes-index__content');
  let newNode = fromHTML(json['html']);

  curNode.replaceWith(newNode);
}

function onFailure(_error) {
  let curNode = document.querySelector('.recipes-index__list');
  let newNode = fromHTML('<span>oops, something went wrong!</span>');

  curNode.replaceWith(newNode);
}

function getCurrentPage() {
  return parseInt(
    document.querySelector('.recipes-index__content').dataset.currentPage
  );
}

function getCurrentSearch() {
  return document.querySelector('.recipes-index__search-input').value;
}

function getCurrentSortBy() {
  return document.querySelector('button.selected').dataset.id;
}

function getCurrentTag() {
  return document.querySelector('.recipes-index__content').dataset.tagScope;
}

export {
  onPaginationNext,
  onPaginationPrev,
  onRecipeSearch,
  onRecipeSearchClear,
  onRecipeSort
};
