(() => {
  const mailtoLink = document.querySelector('[data-mailto-link="true"]');
  const fallbackNote = document.querySelector('[data-mailto-fallback="true"]');

  if (!mailtoLink || !fallbackNote) {
    return;
  }

  const showFallback = () => {
    fallbackNote.classList.remove('hidden');
  };

  mailtoLink.addEventListener('click', () => {
    fallbackNote.classList.add('hidden');

    let fallbackTimer = setTimeout(showFallback, 1200);

    const clearFallback = () => {
      clearTimeout(fallbackTimer);
      fallbackTimer = null;
      document.removeEventListener('visibilitychange', handleVisibilityChange);
      window.removeEventListener('blur', clearFallback);
      window.removeEventListener('pagehide', clearFallback);
    };

    const handleVisibilityChange = () => {
      if (document.visibilityState === 'hidden') {
        clearFallback();
      }
    };

    document.addEventListener('visibilitychange', handleVisibilityChange, {
      once: true,
    });
    window.addEventListener('blur', clearFallback, { once: true });
    window.addEventListener('pagehide', clearFallback, { once: true });
  });
})();
