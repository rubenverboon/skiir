document.addEventListener('DOMContentLoaded', function() {

    //TODO: get all the explanation requests from the server
    var items = [1, 2, 3];

    var ul = document.querySelector('ul');
    for (var idx in items) {
        var item = items[idx];
        ul.innerHTML += '<li>' + item + '</li>';
    }

    var links = document.querySelectorAll("a");
    for (var i = 0; i < links.length; i++) {
        var ln = links[i];
        var location = ln.href;
        ln.onclick = function () {
            chrome.tabs.create({active: true, url: location});
        };
    }
});

// on request item click
// open explanationDialog

// on message from background js: add explanationRequest