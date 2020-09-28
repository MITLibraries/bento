// Creates a cookie to indicate acknowledgment of privacy notice
const setCookie = () => {
  let now = new Date();
  let expiration = new Date(now.setFullYear(now.getFullYear() + 1));
  document.cookie = "mitlibPrivAck=true;domain=.mit.edu;path=/;expires=" + expiration;

  // Remove the privacy notice once the cookie is set
  document.getElementById('privacy-notice').remove();
}

// Fetch privacy notice acknowledgment cookie
const getCookieValue = (cookieName) => {
  // Go no further if cookies are empty
  if (!document.cookie) {
    return null;
  }

  // Split document.cookie into an array
  let cookies = document.cookie.split(';');

  // Initialize this to null so it returns falsey if the value isn't found
  let match = null;

  // Look for the cookie name in the array
  cookies.forEach((element) => {
    let cookiePair = element.split('=');

    if (cookieName == cookiePair[0].trim()) {
      match = decodeURIComponent(cookiePair[1]);
    }
  });

  // Return the cookie value if found (or null otherwise)
  return match;
}

// Display privacy notice if the acknowledgment cookie isn't set
const privacyNotice = () => {
  if (!getCookieValue('mitlibPrivAck')) {
    document.body.innerHTML += `
      <div class="alert alert-banner" id="privacy-notice">
        <div>
          <p>
            <i class="fa fa-info-circle fa-lg"></i>
            By using this website, you consent to the <a href="#">MIT Libraries privacy policy</a>.
           </p>
           <button class="btn button-primary" onClick="setCookie();">I understand</a></button>
        </div>
      </div>
    `;
  }
}

window.onload = () => { privacyNotice(); }
