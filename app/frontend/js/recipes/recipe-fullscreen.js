//
// State
//

let curSlideIdx = 0;
let isTransitioning = false;

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
}

export {
  onRecipeFullscreenClickNext,
  onRecipeFullscreenClickPrev,
  onRecipeFullscreenTrasitionEnd,
  recipeFullscreenClose,
  recipeFullscreenOpen
};
