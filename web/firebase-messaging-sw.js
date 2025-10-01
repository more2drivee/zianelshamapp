importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

// Match the Firebase config used in web/index.html
firebase.initializeApp({
  apiKey: "AIzaSyCY0Cf3BC23p-snT4NB-OzHk9UnDMLLUBc",
  authDomain: "zain-elsham-51fbb.firebaseapp.com",
  projectId: "zain-elsham-51fbb",
  storageBucket: "zain-elsham-51fbb.firebasestorage.app",
  messagingSenderId: "317607212441",
  appId: "1:317607212441:web:10421ee9cffce80d318f08",
  measurementId: "G-4T4PLHZ226"
});

const messaging = firebase.messaging();

// Optional background message handler
messaging.onBackgroundMessage((message) => {
  // Customize notification if needed
});
