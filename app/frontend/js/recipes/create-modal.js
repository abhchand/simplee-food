let state = {
  curSelection: 'new'
};

function importRecipe() {
  const modal = document.querySelector('#recipe-create-modal .modal');

  const importUrl = modal.querySelector('input.modal-input').value;
  const data = JSON.stringify({ url: importUrl });

  lockImportInput();
  lockModal();

  const url = '/api/recipes/import';
  const headers = { Accept: 'application/json' };

  fetch(url, { method: 'POST', headers, body: data })
    .then((response) => {
      unlockImportInput();
      unlockModal();
      return response.ok ? response.json() : Promise.reject(response);
    })
    .then((_json) => {
      // Close modal so if someone hits "back" the state of the page isn't
      // with modal open
      onRecipeCreateModalClose();
      window.location.href = '/recipes';
    })
    .catch((response) => setError());
}

//
// Helpers
//

function clearError() {
  const modalError = document.querySelector(
    '#recipe-create-modal .modal--error'
  );
  modalError.innerHTML = '';
}

function setError() {
  const modalError = document.querySelector(
    '#recipe-create-modal .modal--error'
  );
  modalError.innerHTML = 'Unable to import from URL';
}

function lockImportInput() {
  const modal = document.querySelector('#recipe-create-modal .modal');
  const input = modal.querySelector('input.modal-input');
  input.disabled = true;
}

function unlockImportInput() {
  const modal = document.querySelector('#recipe-create-modal .modal');
  const input = modal.querySelector('input.modal-input');
  input.disabled = false;
}

function lockModal() {
  const modal = document.querySelector('#recipe-create-modal .modal');
  modal
    .querySelectorAll('.btn--hollow')
    .forEach((btn) => (btn.disabled = true));
}

function unlockModal() {
  const modal = document.querySelector('#recipe-create-modal .modal');
  modal
    .querySelectorAll('.btn--hollow')
    .forEach((btn) => (btn.disabled = false));
}

//
// Handlers
//

function onRecipeCreateModalClose() {
  const modal = document.querySelector('#recipe-create-modal .modal');
  modal.classList.add('modal--closed');

  modal.querySelector('input.modal-input').value = '';
}

function onRecipeCreateModalOpen() {
  const modal = document.querySelector('#recipe-create-modal .modal');
  modal.classList.remove('modal--closed');
}

function onRecipeCreateModalImportInputChange() {
  clearError();
}

function onRecipeCreateModalRadioChange(radio) {
  clearError();

  state.curSelection = radio.value;

  if (state.curSelection == 'new') {
    lockImportInput();
  } else {
    unlockImportInput();
  }
}

function onRecipeCreateModalSubmit() {
  if (state.curSelection == 'new') {
    // Close modal so if someone hits "back" the state of the page isn't
    // with modal open
    onRecipeCreateModalClose();
    window.location.href = '/recipes/new';
  } else {
    importRecipe();
  }
}

export {
  onRecipeCreateModalClose,
  onRecipeCreateModalImportInputChange,
  onRecipeCreateModalOpen,
  onRecipeCreateModalRadioChange,
  onRecipeCreateModalSubmit
};
