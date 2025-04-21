import { fromHTML } from './html';

// Generically sets a flash message of type `flashType`, with a given `text`
function setFlashMessage(text, flashType, autoscroll = false) {
  const flash = document.getElementById('flash');
  const span = flash.querySelector('span');

  flash.classList.add('active');
  flash.classList.add(`flash--${flashType}`);

  span.innerHTML = text;

  if (autoscroll) {
    flash.scrollIntoView(true, { behavior: 'smooth' });
  }
}

function setFlashError(text, autoscroll = false) {
  setFlashMessage(text, 'error', autoscroll);
}

function setFlashNotice(text, autoscroll = false) {
  setFlashMessage(text, 'notice', autoscroll);
}

function setFlashSuccess(text, autoscroll = false) {
  setFlashMessage(text, 'success', autoscroll);
}

// Clears current flash message (of any type)
function clearFlash() {
  const flash = document.getElementById('flash');
  const span = flash.querySelector('span');

  // Remove `active` and every class that looks like `flash--*`
  flash.classList.remove('active');
  flash.classList.forEach((cls) => {
    if (/flash\-\-/i.test(cls)) {
      flash.classList.remove(cls);
    }
  });

  span.innerHTML = '';
}

export { clearFlash, setFlashError, setFlashNotice, setFlashSuccess };
