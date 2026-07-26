const NATIVE_HOST = "dev.quickshell.focus";
const BLOCK_RULE_BASE = 1;
const temporaryRules = new Map();
const attemptedUrls = new Map();
let state = { active: false, endsAt: 0, label: "", domains: [] };
let nativePort = null;
let reconnectTimer = null;

function domainPattern(domain) {
  return `||${domain}^`;
}

async function applyState(nextState) {
  state = nextState || { active: false, endsAt: 0, label: "", domains: [] };
  await chrome.storage.local.set({ focusState: state });
  const existingRules = await chrome.declarativeNetRequest.getDynamicRules();
  const removeRuleIds = existingRules.map(rule => rule.id);
  const addRules = [];
  if (state.active && state.endsAt * 1000 > Date.now() && state.domains?.length) {
    state.domains.forEach((domain, index) => addRules.push({
      id: BLOCK_RULE_BASE + index,
      priority: 1,
      action: { type: "redirect", redirect: { extensionPath: "/blocked.html" } },
      condition: {
        urlFilter: domainPattern(domain),
        resourceTypes: ["main_frame"]
      }
    }));
  }
  await chrome.declarativeNetRequest.updateDynamicRules({ removeRuleIds, addRules });
}

function connectNative() {
  clearTimeout(reconnectTimer);
  try {
    nativePort = chrome.runtime.connectNative(NATIVE_HOST);
    nativePort.onMessage.addListener(message => applyState(message));
    nativePort.onDisconnect.addListener(() => {
      nativePort = null;
      reconnectTimer = setTimeout(connectNative, 2000);
    });
  } catch (_) {
    reconnectTimer = setTimeout(connectNative, 5000);
  }
}

chrome.webRequest.onBeforeRequest.addListener(details => {
  if (!state.active || details.type !== "main_frame") return;
  try {
    const host = new URL(details.url).hostname;
    if (state.domains.some(domain => host === domain || host.endsWith(`.${domain}`)))
      attemptedUrls.set(details.tabId, details.url);
  } catch (_) {}
}, { urls: ["<all_urls>"], types: ["main_frame"] });

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === "status") {
    sendResponse({ state, attemptedUrl: attemptedUrls.get(sender.tab?.id) || "" });
    return;
  }
  if (message.type === "temporaryAccess" && sender.tab?.id !== undefined) {
    const url = attemptedUrls.get(sender.tab.id);
    if (!url) { sendResponse({ ok: false }); return; }
    const host = new URL(url).hostname;
    const ruleId = 1000 + sender.tab.id;
    chrome.declarativeNetRequest.updateSessionRules({
      removeRuleIds: [ruleId],
      addRules: [{
        id: ruleId,
        priority: 2,
        action: { type: "allow" },
        condition: { urlFilter: `||${host}^`, tabIds: [sender.tab.id], resourceTypes: ["main_frame"] }
      }]
    }).then(() => {
      temporaryRules.set(ruleId, Date.now() + 300000);
      chrome.alarms.create(`focus-allow-${ruleId}`, { delayInMinutes: 5 });
      chrome.tabs.update(sender.tab.id, { url });
      sendResponse({ ok: true });
    });
    return true;
  }
});

chrome.alarms.onAlarm.addListener(alarm => {
  if (!alarm.name.startsWith("focus-allow-")) return;
  const ruleId = Number(alarm.name.slice("focus-allow-".length));
  chrome.declarativeNetRequest.updateSessionRules({ removeRuleIds: [ruleId] });
  temporaryRules.delete(ruleId);
});

chrome.runtime.onStartup.addListener(connectNative);
chrome.runtime.onInstalled.addListener(connectNative);
chrome.storage.local.get("focusState").then(result => applyState(result.focusState || state));
connectNative();
