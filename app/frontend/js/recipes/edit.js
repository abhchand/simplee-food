import { setFlashError } from '../shared/flash';

let newTagId = 1000;

function onImageSelect(event) {
  const file = event.currentTarget.files;

  if (file) {
    const fileReader = new FileReader();
    const preview = document.querySelector('.recipes-edit__image-preview img');

    fileReader.onload = function (event) {
      preview.setAttribute('src', event.target.result);
    };
    fileReader.readAsDataURL(file[0]);
  }
}

function onAddTag(_event) {
  let name = prompt('Enter a name for the new Tag');

  if (!name) {
    return;
  }

  // The frontend doesn't have the ability to easily calculate the slug. But
  // all we really need is a unique value for this `name` for the CSS ID.
  // Settle for using a global counter
  const slug = `fake-slug-${newTagId}`;
  newTagId += 1;

  const input = document.createElement('input');
  input.type = 'checkbox';
  input.id = `recipe_tag_ids_${slug}`;
  input.setAttribute('checked', 'checked');
  input.name = 'recipe[tag_names][]';
  input.value = name;

  const label = document.createElement('label');
  label.htmlFor = `recipe_tag_ids_${slug}`;
  label.innerHTML = name;

  const li = document.createElement('li');
  li.appendChild(input);
  li.appendChild(label);

  const ul = document.querySelector('.recipes-edit__tags');
  ul.appendChild(li);
}

function onEditRecipeSubmit(event) {
  event.preventDefault();

  disableSaveButtons();

  const form = document.querySelector('form.recipes-edit__form');
  const formData = new FormData(form);

  // Counter-intuitively, we shouldn't set `Content-Type` when posting form data
  // See: https://muffinman.io/blog/uploading-files-using-fetch-multipart-form-data/
  const headers = { Accept: 'application/json' };
  const url = `/api/recipes/${form.dataset.recipeSlug}`;

  fetch(url, { method: 'PUT', headers, body: formData })
    .then((response) => {
      return response.ok ? response.json() : Promise.reject(response);
    })
    .then((json) => (window.location.href = json.url))
    .catch((response) => {
      enableSaveButtons();
      console.log(response.status, response.statusText);
      response.json().then((json) => setFlashError(json.error, true));
    });
}

function disableSaveButtons() {
  document.querySelectorAll('.recipes-edit__save-btn').forEach((btn) => {
    btn.disabled = true;
    btn.textContent = 'Saving...';
  });
}

function enableSaveButtons() {
  document.querySelectorAll('.recipes-edit__save-btn').forEach((btn) => {
    btn.disabled = false;
    btn.textContent = 'Save';
  });
}

/*
 * Sortable List Handlers
 */

function addSortableListItem(css_id, value = null) {
  // Last index is length-1, so next index is length
  const nextIdx = document.querySelectorAll(
    `#${css_id} .recipes-edit__sortable-list li`
  ).length;

  // "recipe-ingredients" -> "ingredients"
  const suffix = css_id.replace(/recipe\-/, '');

  // Clone reference SVG icons to build new DOM element
  const arrowDownIcon = document
    .querySelector('#reference_icons .arrow-down svg')
    .cloneNode(true);
  const arrowUpIcon = document
    .querySelector('#reference_icons .arrow-up svg')
    .cloneNode(true);
  const trashIcon = document
    .querySelector('#reference_icons .trash svg')
    .cloneNode(true);

  const li = document.createElement('li');
  li.classList.add('recipes-edit__sortable-list-row');

  // The one major difference between the "ingredients" and "instructions"
  // section is that the latter uses textarea instead of input fields.
  let input;
  if (css_id == 'recipe-ingredients') {
    input = document.createElement('input');
    input.name = `recipe[ingredients][${nextIdx}]`;
  } else {
    input = document.createElement('textarea');
    input.name = `recipe[instructions][${nextIdx}]`;
  }

  if (value) {
    input.value = value;
  }

  // Build buttons

  const arrowUpButton = document.createElement('button');
  arrowUpButton.type = 'button';
  arrowUpButton.setAttribute(
    'onclick',
    'SimpleeFood.moveSortableListItemUp(event)'
  );
  arrowUpButton.appendChild(arrowUpIcon);

  const arrowDownButton = document.createElement('button');
  arrowDownButton.type = 'button';
  arrowDownButton.setAttribute(
    'onclick',
    'SimpleeFood.moveSortableListItemDown(event)'
  );
  arrowDownButton.appendChild(arrowDownIcon);

  const trashButton = document.createElement('button');
  trashButton.type = 'button';
  trashButton.setAttribute(
    'onclick',
    'SimpleeFood.deleteSortableListItem(event)'
  );
  trashButton.appendChild(trashIcon);

  li.appendChild(input);
  li.appendChild(arrowUpButton);
  li.appendChild(arrowDownButton);
  li.appendChild(trashButton);

  const ul = document.querySelector(`#${css_id} .recipes-edit__sortable-list`);
  ul.appendChild(li);
}

function bulkAddSortableListItems(css_id) {
  const modal = document.querySelector(`#${css_id} .modal`);
  const text = modal.querySelector('textarea').value;

  text.split('\n').forEach((line) => addSortableListItem(css_id, line));
  closeBulkAddModal(css_id);
}

function deleteSortableListItem(event) {
  const button = event.currentTarget;
  const item = button.closest('li');
  const sortableList = button.closest('ul');

  item.parentNode.removeChild(item);

  renumberSortableList(sortableList);
}

function moveSortableListItem(clickedItem, shiftBy) {
  const sortableList = clickedItem.closest('ul');
  const items = [...sortableList.querySelectorAll('li')];

  const curIdx = items.indexOf(clickedItem);
  const newIdx = curIdx + shiftBy;

  // If incrementing or decrementing takes us out of bounds, don't do it
  if (newIdx < 0 || newIdx >= items.length) {
    return;
  }

  // Move item to new position by re-structuring the list
  const curItem = items[curIdx];
  const newItem = items[newIdx];
  const refNode = newIdx > curIdx ? newItem.nextSibling : newItem;
  sortableList.insertBefore(curItem, refNode);

  // Since the list is re-ordered, we need to re-number the form element names
  renumberSortableList(sortableList);

  // Add temporary highlighting to the item that was moved
  curItem.classList.add('selected');
  setTimeout(clearSelectedSortableItems, 1000);
}

function moveSortableListItemDown(event) {
  const clickedItem = event.target.closest('li');
  moveSortableListItem(clickedItem, 1);
}

function moveSortableListItemUp(event) {
  const clickedItem = event.target.closest('li');
  moveSortableListItem(clickedItem, -1);
}

/*
 * Modal Actions
 */

function closeBulkAddModal(css_id) {
  const modal = document.querySelector(`#${css_id} .modal`);
  modal.classList.add('modal--closed');

  modal.querySelector('textarea').value = '';
}

function openBulkAddModal(css_id) {
  const modal = document.querySelector(`#${css_id} .modal`);
  modal.classList.remove('modal--closed');
  modal.querySelector('textarea').focus();
}

/*
 * Sortable List Helpers
 */

function renumberSortableList(sortableList) {
  let idx = 0;

  [...sortableList.querySelectorAll('li > input,textarea')].forEach((input) => {
    // Replace the last number with the current index
    // e.g. foo[bar][9] -> foo[bar][<count>]
    input.name = input.name.replace(/\[\d+\]/, `[${idx}]`);
    idx += 1;
  });
}

// Safely removes the `selected` class
function clearSelectedSortableItems() {
  const el = document.querySelector(
    '.recipes-edit__sortable-list-row.selected'
  );
  if (!el) {
    return;
  }

  el.classList.remove('selected');
}

export {
  addSortableListItem,
  bulkAddSortableListItems,
  closeBulkAddModal,
  deleteSortableListItem,
  moveSortableListItemDown,
  moveSortableListItemUp,
  onAddTag,
  onEditRecipeSubmit,
  onImageSelect,
  openBulkAddModal
};
