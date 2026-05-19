importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDswy9wShkZGne6G0bMOoiiyR_gj3a6dzU",
  authDomain: "unidesk-c5bfb.firebaseapp.com",
  projectId: "unidesk-c5bfb",
  storageBucket: "unidesk-c5bfb.firebasestorage.app",
  messagingSenderId: "732438605479",
  appId: "1:732438605479:web:16e1e35a2d2de934a53582",
  measurementId: "G-S2CSVB8TTV",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Background message received:", payload);

  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  });
});