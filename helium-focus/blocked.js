let focusState = { endsAt: 0, label: "" };
let waitRemaining = 15;
let waitTimer = null;

const label = document.querySelector("#label");
const remaining = document.querySelector("#remaining");
const request = document.querySelector("#request");
const override = document.querySelector("#override");
const reason = document.querySelector("#reason");
const grant = document.querySelector("#grant");

document.querySelector("#back").addEventListener("click", () => history.back());
request.addEventListener("click", () => {
  request.hidden = true;
  override.hidden = false;
  reason.focus();
  waitTimer = setInterval(() => {
    waitRemaining -= 1;
    grant.textContent = waitRemaining > 0 ? `Wait ${waitRemaining} seconds` : "Grant 5 minutes";
    if (waitRemaining <= 0) {
      clearInterval(waitTimer);
      grant.disabled = reason.value.trim().length < 8;
    }
  }, 1000);
});
reason.addEventListener("input", () => {
  if (waitRemaining <= 0) grant.disabled = reason.value.trim().length < 8;
});
grant.addEventListener("click", () => {
  if (grant.disabled) return;
  grant.disabled = true;
  chrome.runtime.sendMessage({ type: "temporaryAccess", reason: reason.value.trim() }, response => {
    if (!response?.ok) {
      grant.textContent = "Could not grant access";
      grant.disabled = false;
    }
  });
});

function updateClock() {
  const seconds = Math.max(0, focusState.endsAt - Math.floor(Date.now() / 1000));
  remaining.textContent = `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, "0")}`;
  if (!seconds) location.reload();
}

chrome.runtime.sendMessage({ type: "status" }, response => {
  focusState = response?.state || focusState;
  label.textContent = focusState.label ? `You chose to focus on: ${focusState.label}` : "You chose to protect this time.";
  updateClock();
  setInterval(updateClock, 1000);
});
