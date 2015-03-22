function getTextInfo(searchText, callback, errorCallback) {

  //local PHP page
  var localUrl = 'http://localhost/ir/home.php';

  //Post call that receives HMTL text with abstract(s)
  $.post(localUrl, {text:searchText}, function(data,status,xhr) {
    var result = data;
    console.log(result);
    callback(result);
  });
}

//Just an output screen from the button down
function renderStatus(statusText) {
  var status = document.getElementById('status');
  //status.textContent = statusText;
  status.innerHTML = statusText;
}

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
    
    chrome.extension.getBackgroundPage().getPageDetails(function(msg){
        //Start call for disambiguation and abstract(s) from DBPedia
        getTextInfo(msg['selection'], renderStatus, renderStatus);
      });
});

// on request item click
// open explanationDialog

// on message from background js: add explanationRequest