//
// State
//

let curSlideIdx = 0;
let isTransitioning = false;
let isOpen = false;
let wakeLock = null;

//
// DOM References
//

let body, fullScreen, progressBar, slides, slideWrapper;

//
// Navigate Slides
//

function onRecipeFullscreenClickNext() {
  if (isTransitioning || curSlideIdx >= slides.length - 1) {
    return;
  }

  isTransitioning = true;
  moveToSlide(curSlideIdx + 1);
}

function onRecipeFullscreenClickPrev() {
  if (curSlideIdx === 0 || isTransitioning) {
    return;
  }

  isTransitioning = true;
  moveToSlide(curSlideIdx - 1);
}

function moveToSlide(newSlideIdx) {
  // Calculate old and new slide
  const oldSlideIdx = curSlideIdx;
  curSlideIdx = newSlideIdx;

  // Move Slide
  slideWrapper.style.transform = `translateX(-${curSlideIdx * 100}%)`;

  // Update progress bar
  const pct = Math.round((100 * curSlideIdx) / (slides.length - 1));
  progressBar.style.width = `${pct}%`;

  // Reset the old (non-visible) slide by scrolling to the top
  slides[oldSlideIdx].scrollTop = 0;
}

function onRecipeFullscreenTrasitionEnd() {
  isTransitioning = false;
}

//
// Screen Wake Lock
//

// Keeps the screen from dimming/sleeping while cooking mode is open.
// `navigator.wakeLock` only works in secure contexts (HTTPS or localhost).

async function acquireWakeLock() {
  if (!('wakeLock' in navigator) || wakeLock) {
    return;
  }

  try {
    wakeLock = await navigator.wakeLock.request('screen');

    // The browser releases the lock on its own whenever the page is hidden
    // (tab switch, app switch, device locked). Clear our reference so it can
    // be re-acquired when the page becomes visible again.
    wakeLock.addEventListener('release', () => {
      wakeLock = null;
    });
  } catch (err) {
    // Denied (e.g. battery saver, page not visible) - not worth surfacing
    wakeLock = null;
  }
}

function releaseWakeLock() {
  if (!wakeLock) {
    return;
  }

  wakeLock.release().catch(() => {});
  wakeLock = null;
}

document.addEventListener('visibilitychange', () => {
  if (isOpen && document.visibilityState === 'visible') {
    acquireWakeLock();
  }
});

//
// Open/Close Modal
//

function recipeFullscreenOpen() {
  // Initializes DOM references
  body = document.querySelector('body');
  fullScreen = document.querySelector('.recipe-fullscreen');
  progressBar = document.querySelector('.recipe-fullscreen__progress-value');
  slides = document.querySelectorAll('.recipe-fullscreen__slide');
  slideWrapper = document.querySelector('.recipe-fullscreen__slide-wrapper');

  // Open the modal
  fullScreen.classList.add('open');
  body.classList.add('recipe-fullscreen--open');

  // Keep the screen on while cooking
  isOpen = true;
  acquireWakeLock();
}

function recipeFullscreenClose() {
  // Sroll to the top of the first slide.
  // `scrollTop` does not work on hidden elements so we must do this manually
  // *before* hiding the element directly below and moving the slide to 0.
  slides[0].scrollTop = 0;

  fullScreen.classList.remove('open');
  body.classList.remove('recipe-fullscreen--open');

  // Reset slides back to initial
  moveToSlide(0);

  // Let the screen sleep normally again
  isOpen = false;
  releaseWakeLock();
}

export {
  onRecipeFullscreenClickNext,
  onRecipeFullscreenClickPrev,
  onRecipeFullscreenTrasitionEnd,
  recipeFullscreenClose,
  recipeFullscreenOpen
};
