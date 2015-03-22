// The onClicked callback function.
function onClickHandler(info, tab) {

    var details = {
        phrase: info.selectionText,
        pageUrl: info.pageUrl
    };

    chrome.tabs.sendMessage(tab.id, {details: details});
}

// This function is called on load in the popup code
function getPageDetails(callback) { 
    console.log("getPageDetails");
    // Inject the content script into the current page 
    chrome.tabs.executeScript(null, { file: 'selection.js' }); 
    // Perform the callback when a message is received from the content script
    chrome.runtime.onMessage.addListener(function(message)  { 
        console.log("something else");
        // Call the callback function
        callback(message); 
    }); 
};

chrome.runtime.onInstalled.addListener(function() {
    // Replace all rules ...
    chrome.declarativeContent.onPageChanged.removeRules(undefined, function() {
        // With a new rule ...
        chrome.declarativeContent.onPageChanged.addRules([
            {
                // That fires when a page's URL contains a 'g' ...
                conditions: [
                    new chrome.declarativeContent.PageStateMatcher({
                        pageUrl: { hostEquals: 'www.bloomberg.com' }
                    })
                ],
                // And shows the extension's page action.
                actions: [ new chrome.declarativeContent.ShowPageAction() ]
            }
        ]);
    });

    // Set up context menu at install time.
    var id = chrome.contextMenus.create({
        title: "Can someone explain this?",
        contexts: ["selection"],
        documentUrlPatterns: ["http://www.bloomberg.com/*"],
        id: "contextSelection"
    });

});
// add click event
chrome.contextMenus.onClicked.addListener(onClickHandler);



chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
});