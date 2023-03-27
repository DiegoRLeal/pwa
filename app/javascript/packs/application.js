// External imports
import "bootstrap";
// Internal imports
import askPushNotifications from '../plugins/push_notifications';

window.addEventListener('load', () => {
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register('/service-worker.js').then(registration => {
      console.log('ServiceWorker registered: ', registration);

      var serviceWorker;
      if (registration.installing) {
        serviceWorker = registration.installing;
        console.log('Service worker installing.');
      } else if (registration.waiting) {
        serviceWorker = registration.waiting;
        console.log('Service worker installed & waiting.');
      } else if (registration.active) {
        serviceWorker = registration.active;
        console.log('Service worker active.');
      }

      window.Notification.requestPermission().then(permission => {
        if(permission !== 'granted'){
          throw new Error('Permission not granted for Notification');
        }
      });
    }).catch(registrationError => {
      console.log('Service worker registration failed: ', registrationError);
    });
  }
});


// force to relaod the page when internet connexion is offline to render the offline page in cache
window.addEventListener('offline', () => {
  window.location.reload();
});



document.addEventListener('turbolinks:load', () => {
  askPushNotifications();
});





class CookieBar {
  constructor() {
    this.cookiesBar = document.getElementById('cookies-bar');
  }

  init() {
    if (this.cookiesAllowed()) {
      this.appendGACode();
    }

    this.addButtonBehaviors();
  }

  cookiesAllowed() {
    return Cookies.get('allow_cookies') === 'yes';
  }

  addButtonBehaviors() {
    if (!this.cookiesBar) {
      return;
    }

    this.cookiesBar.querySelector('.accept').addEventListener('click', () => this.allowCookies(true));

    this.cookiesBar.querySelector('.reject').addEventListener('click', () => this.allowCookies(false));
  }

  appendGACode() {
    const ga = "(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){" +
      "(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o)," +
      "m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)" +
      "})(window,document,'script','//www.google-analytics.com/analytics.js','ga');" +
      "ga('create', 'UA-XXXXX-Y', 'auto');" + "ga('send', 'pageview');";

    document.getElementsByTagName('head')[0].append('<script>' + ga + '</script>');
  }

  allowCookies(allow) {
    if (allow) {
      Cookies.set('allow_cookies', 'yes', {
        expires: 365
      });

      this.appendGACode();
    } else {
      Cookies.set('allow_cookies', 'no', {
        expires: 365
      });
    }

    this.cookiesBar.classList.add('hidden');
  }
}

window.onload = function() {
  const cookieBar = new CookieBar();

  cookieBar.init();
}
