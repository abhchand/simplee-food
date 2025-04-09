import { fromHTML } from './html';

// Sets a flash message of type 'error'
function setFlashError(text, autoscroll = false) {
  const flash = document.getElementById('flash');
  const span = flash.querySelector('span');

  flash.classList.add('active');
  flash.classList.add('flash--error');

  span.innerHTML = text;

  if (autoscroll) {
    flash.scrollIntoView(true, { behavior: 'smooth' });
  }
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

export { clearFlash, setFlashError };
