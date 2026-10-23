// Create a lightweight loading overlay before Flutter paints its first frame.
(() => {
  const style = document.createElement('style');
  style.textContent = `
    #app-loader {
      position: fixed;
      inset: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      background: radial-gradient(circle at top, #fff4e8 0%, #fbf5ef 45%, #f0ded4 100%);
      z-index: 9999;
      opacity: 1;
      visibility: visible;
      transition: opacity 320ms ease, visibility 320ms ease;
      font-family: "Segoe UI", sans-serif;
    }

    #app-loader.app-loader--hidden {
      opacity: 0;
      visibility: hidden;
      pointer-events: none;
    }

    .app-loader__content {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 18px;
      text-align: center;
      color: #6f1718;
    }

    .app-loader__rings {
      position: relative;
      width: 112px;
      height: 112px;
    }

    .app-loader__ring {
      position: absolute;
      inset: 0;
      border: 4px solid rgba(159, 29, 32, 0.16);
      border-top-color: #9f1d20;
      border-radius: 50%;
      animation: loader-spin 1.15s linear infinite;
    }

    .app-loader__ring:nth-child(2) {
      inset: 14px;
      border-top-color: #d06f39;
      animation-duration: 1.45s;
      animation-direction: reverse;
    }

    .app-loader__ring:nth-child(3) {
      inset: 28px;
      border-top-color: #f0ad4e;
      animation-duration: 1.8s;
    }

    .app-loader__title {
      margin: 0;
      font-size: 1.25rem;
      font-weight: 700;
      letter-spacing: 0.03em;
    }

    .app-loader__subtitle {
      margin: 0;
      font-size: 0.95rem;
      color: #8a5354;
    }

    @keyframes loader-spin {
      from {
        transform: rotate(0deg);
      }

      to {
        transform: rotate(360deg);
      }
    }
  `;

  document.head.appendChild(style);

  const loader = document.createElement('div');
  loader.id = 'app-loader';
  loader.innerHTML = `
    <div class="app-loader__content">
      <div class="app-loader__rings" aria-hidden="true">
        <span class="app-loader__ring"></span>
        <span class="app-loader__ring"></span>
        <span class="app-loader__ring"></span>
      </div>
      <div>
        <p class="app-loader__title">Loading Inventory App</p>
        <p class="app-loader__subtitle">Preparing data and opening the dashboard...</p>
      </div>
    </div>
  `;

  document.body.prepend(loader);

  let isHidden = false;

  // Remove the overlay after Flutter renders, with a timeout fallback for safety.
  const hideLoader = () => {
    if (isHidden) {
      return;
    }

    isHidden = true;
    loader.classList.add('app-loader--hidden');
    window.setTimeout(() => loader.remove(), 400);
  };

  window.addEventListener('flutter-first-frame', hideLoader, { once: true });
  window.setTimeout(hideLoader, 15000);
})();
