import { setFlashError } from '../shared/flash';

let draggedItem = null;
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

  const form = document.querySelector('form.recipes-edit__form');
  const formData = new FormData(form);

  // Counter-intuitively, we shouldn't set `Content-Type` when posting form data
  // See: https://muffinman.io/blog/uploading-files-using-fetch-multipart-form-data/
  const headers = { Accept: 'application/json' };
  const url = `/api/recipes/${form.dataset.recipeSlug}`;

  fetch(url, { method: 'POST', headers, body: formData })
    .then((response) => {
      return response.ok ? response.json() : Promise.reject(response);
    })
    .then((json) => (window.location.href = json.url))
    .catch((response) => {
      console.log(response.status, response.statusText);
      response.json().then((json) => setFlashError(json.error));
    });
}

/*
 * Add Draggable List Items
 */

function addDraggableListItem(css_id, value = null) {
  // Last index is length-1, so next index is length
  const nextIdx = document.querySelectorAll(
    `#${css_id} .recipes-edit__draggable-list li`
  ).length;

  // "recipe-ingredients" -> "ingredients"
  const suffix = css_id.replace(/recipe\-/, '');

  const dragIcon = document
    .querySelector('#reference_icons .drag-icon svg')
    .cloneNode(true);
  const trashIcon = document
    .querySelector('#reference_icons .trash svg')
    .cloneNode(true);

  const li = document.createElement('li');
  li.draggable = true;
  li.classList.add('recipes-edit__draggable-list-row');

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

  const button = document.createElement('button');
  button.type = 'button';
  button.setAttribute('onclick', 'SimpleeFood.onDraggableItemDelete(event)');
  button.appendChild(trashIcon);

  li.appendChild(dragIcon);
  li.appendChild(input);
  li.appendChild(button);

  const ul = document.querySelector(`#${css_id} .recipes-edit__draggable-list`);
  ul.appendChild(li);
}

function bulkAddDraggableListItems(css_id) {
  const modal = document.querySelector(`#${css_id} .modal`);
  const text = modal.querySelector('textarea').value;

  text.split('\n').forEach((line) => addDraggableListItem(css_id, line));
  closeBulkAddModal(css_id);
}

/*
 * Modal Handlers
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
 * Draggable List Event Handlers
 *
 * Dragging logic adapted from
 * https://www.geeksforgeeks.org/create-a-drag-and-drop-sortable-list-using-html-css-javascript/
 */

function onDragStart(event) {
  draggedItem = event.target;
  draggedItem.classList.add('dragging');

  // Style needs to be set async to show as draggable in the browser
  setTimeout(() => {
    event.target.style.display = 'none';
  }, 0);
}

function onDragEnd(event) {
  clearDraggingBumpers();

  // Style needs to be set async to show as draggable in the browser
  setTimeout(() => {
    event.target.style.display = '';
    draggedItem.classList.remove('dragging');
    draggedItem = null;

    // The event target should be the `<li>` that was dragged
    const sortableList = event.target.closest('ul');
    renumberDraggableList(sortableList);
  }, 0);
}

function onDragOver(event) {
  event.preventDefault();

  // The event target itself should be the top level `<ul>` container
  const sortableList = event.currentTarget;
  // Find "after element", the element just below the currently dragged item.
  const afterElement = getDragAfterElement(sortableList, event.clientY);

  if (afterElement == null) {
    sortableList.appendChild(draggedItem);
  } else {
    // We add dragging bumpers, which is a styling that provides some spacing
    // between the currently dragged element and the list below it.
    clearDraggingBumpers();
    afterElement.classList.add('dragging-bumper');
    sortableList.insertBefore(draggedItem, afterElement);
  }
}

function onDraggableItemDelete(event) {
  const button = event.currentTarget;
  const item = button.closest('li');
  const sortableList = button.closest('ul');

  item.parentNode.removeChild(item);

  renumberDraggableList(sortableList);
}

function clearDraggingBumpers() {
  document.querySelectorAll('.dragging-bumper').forEach((el) => {
    el.classList.remove('dragging-bumper');
  });
}

function getDragAfterElement(container, y) {
  const draggableElements = [
    ...container.querySelectorAll('li:not(.dragging)')
  ];

  return draggableElements.reduce(
    (closest, element) => {
      const box = element.getBoundingClientRect();
      const offset = y - box.top - box.height / 2;

      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: element };
      } else {
        return closest;
      }
    },
    { offset: Number.NEGATIVE_INFINITY }
  ).element;
}

function renumberDraggableList(sortableList) {
  let idx = 0;

  [...sortableList.querySelectorAll('li > input')].forEach((input) => {
    // Replace the last number with the current index
    // e.g. foo[bar][9] -> foo[bar][<count>]
    input.name = input.name.replace(/\[\d+\]/, `[${idx}]`);
    idx += 1;
  });
}

export {
  addDraggableListItem,
  bulkAddDraggableListItems,
  closeBulkAddModal,
  openBulkAddModal,
  onDraggableItemDelete,
  onDragEnd,
  onDragOver,
  onDragStart,
  onImageSelect,
  onAddTag,
  onEditRecipeSubmit
};
