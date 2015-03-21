function getTextInfo(searchText, callback, errorCallback) {

  //local PHP page
  var localUrl = 'http://localhost/ir/home.php';

  //Post call that receives HMTL text with abstract(s)
  $.post(localUrl, {text:searchText}, function(data,status,xhr) {
    var result = data;
    callback(result);
  });
}

//Just an output screen from the button down
function renderStatus(statusText) {
  var status = document.getElementById('status');
  //status.textContent = statusText;
  status.innerHTML = statusText;
}

//On document loaded
document.addEventListener('DOMContentLoaded', 
  function() {
    //Get the active page
    chrome.runtime.getBackgroundPage(function(eventPage){
      eventPage.getPageDetails(function(msg){
        //Start call for disambiguation and abstract(s) from DBPedia
        getTextInfo(msg['selection'], renderStatus, renderStatus);
      });
    });
});