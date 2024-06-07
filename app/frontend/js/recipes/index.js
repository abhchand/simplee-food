function onRecipeSearch(_event) {
  // Reset the page to the first each time we search
  renderRecipeList({ page: 1 });
}

function onRecipeShare(event) {
  const clicked = event.currentTarget;
  const item = clicked.closest('.recipe-item');

  // Copy to clipboard
  if (location.protocol !== 'https:') {
    setFlashError('https is required to copy to clipboard');
    return;
  }
  if (!navigator.clipboard) {
    setFlashError('copying to clipboard is not supported in your browser.');
    return;
  }
  navigator.clipboard
    .writeText(window.location.origin + '/recipes/' + item.dataset.id)
    .catch(() => setFlashError('could not copy to clipboard'));

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

// Source: https://stackoverflow.com/a/35385518/2490003
function fromHTML(html, trim = true) {
  // Process the HTML string.
  html = trim ? html.trim() : html;
  if (!html) return null;

  // Then set up a new template element.
  const template = document.createElement('template');
  template.innerHTML = html;
  const result = template.content.children;

  // Then return either an HTMLElement or HTMLCollection,
  // based on whether the input HTML had one or more roots.
  if (result.length === 1) return result[0];
  return result;
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

function setFlashError(text) {
  const span = fromHTML(`<span>${text}</span>`);
  const dismiss = fromHTML(
    `<a href="" onclick="clearFlashError()">(dismiss)</a>`
  );

  const flash = document.getElementById('flash');
  flash.appendChild(span);
  flash.appendChild(dismiss);
}

function clearFlashError() {
  document.getElementById('flash').innerHTML = '';
}

export {
  onPaginationNext,
  onPaginationPrev,
  onRecipeSearch,
  onRecipeShare,
  onRecipeSort
};
