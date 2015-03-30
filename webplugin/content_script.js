// Test Url:
// http://www.bloomberg.com/news/articles/2015-03-15/germans-tired-of-greek-demands-want-country-to-exit-euro

var testExReqs = [
  {
    id: 1,
    original: 'Mueller’s sentiment is shared by a majority of Germans. A poll published March 13 by public broadcaster ZDF found 52 percent of his countrymen no longer want Greece to remain in Europe’s common currency, up from 41 percent last month. The shift is due to a view held by 80 percent of Germans that Greece’s government “isn’t behaving seriously toward its European partners.” ',
    phrase: 'Mueller’s sentiment'
  },
  {
    id: 2,
    original: '“It’s so frustrating that they constantly criticize us, that they don’t appreciate our help,” said Erika Schmidt, a 53-year-old kindergarten teacher from Augsburg. “I’ve got nothing against Greece, but the way they behave and talk about Germany makes me angry.”',
    phrase: 'frustrating that they constantly criticize us'
  }
];

var testExs = [
  {
    id: 1,
    original: 'Tsipras has also stepped up calls for war reparations from Germany for the Nazi occupation during World War II and Greek Finance Minister Yanis Varoufakis has been locked in a war of words with his German counterpart Wolfgang Schaeuble. Last week, the Greek government officially complained about Schaeuble’s conduct, to which Schaeuble replied that the whole matter was “absurd.”',
    phrase: 'Tsipras has also stepped up calls for war reparations',
    explanation: 'Greece’s Prime Minister Alexis Tsipras is to visit Germany’s Angela Merkel head-to-head for the first time next Monday. The talks, scheduled for Monday, will try to repair relations that have deteriorated badly in the last few days, with Tsipras reviving claims for Nazi-era war damages before parliament, and his Justice Minister preparing a law that would allow the seizure of German state property in Greece.'
  },
  {
    id: 2,
    original: '“They’ve got a lot of hubris and arrogance, being in the situation they’re in and making all these demands,” said Mueller, 49, waiting for fares near the Brandenburg Gate. “Maybe it’s better for Greece to just leave the euro.”',
    phrase: "a lot of hubris and arrogance",
    explanation: "52% of Germans want Greece out of Euro, tire of its “arrogance”",
    links: ['http://www.bloomberg.com/news/articles/2015-03-30/greek-markets-show-all-at-risk-should-mistake-trigger-a-default']
  },
  {
    id: 3,
    original: 'The hardening of German opinion is significant because the country is the biggest contributor to Greece’s 240 billion-euro ($253 billion) twin bailouts and the chief proponent of budget cuts and reforms in return for aid. Tensions have been escalating between the two governments since Prime Minister Alexis Tsipras took office in January, promising to end an austerity drive that he blames on Chancellor Angela Merkel.',
    phrase: 'Tsipras took office in January',
    explanation: 'Alexis Tsipras, leader of the (extreme) left Syriza party, was sworn in Monday January 26, 2015 as Greek prime minister, setting the stage for a showdown with creditors over painful budget cuts and tax increases that could have potential ripple effects across the European Union.'
  }
];

$.extend($.expr[':'], {
    containsEscaped: function (el, index, m) {  
        var s = unescape(m[3]).replace(/[\s\n]+/g," ").trim();
        return $(el).text().replace(/[\s\n]+/g," ").indexOf(s) >= 0;
    }  
});

var explanationRequests = [], explanations = [];

var dialogHtml =
    '<h3></h3>'+
    '<button id="close">&#x2716;</button>'+
    '<p id="context"></p>'+
    '<textarea placeholder="write an explanation here"></textarea>'+
    '<button id="done">Done</button>'+
    '<div id="snippets"></div>'
    ;

var dummySnippets =
    '<div>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam lobortis leo in cursus vehicula. Nam eget diam commodo, aliquam ante nec, imperdiet leo. Aliquam vestibulum turpis et orci laoreet cursus. Sed purus ipsum, venenatis convallis mi ac, finibus sagittis risus. Sed lobortis nisl in sapien aliquam, eu ullamcorper tellus condimentum. Vestibulum et urna ut nulla commodo sollicitudin ac nec mauris. Vestibulum sodales, neque vitae blandit finibus, sem nibh suscipit odio, non rhoncus nibh nulla sagittis sapien. Fusce pulvinar purus at ante scelerisque, in semper nibh venenatis. Vestibulum sed massa id massa blandit ornare eget vel elit. Mauris maximus feugiat augue non accumsan. Pellentesque porta at ligula ac mollis.<label><input type="checkbox">add link</label></div>'+
    '<div>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam lobortis leo in cursus vehicula. Nam eget diam commodo, aliquam ante nec, imperdiet leo. Aliquam vestibulum turpis et orci laoreet cursus. Sed purus ipsum, venenatis convallis mi ac, finibus sagittis risus. Sed lobortis nisl in sapien aliquam, eu ullamcorper tellus condimentum. Vestibulum et urna ut nulla commodo sollicitudin ac nec mauris. Vestibulum sodales, neque vitae blandit finibus, sem nibh suscipit odio, non rhoncus nibh nulla sagittis sapien. Fusce pulvinar purus at ante scelerisque, in semper nibh venenatis. Vestibulum sed massa id massa blandit ornare eget vel elit. Mauris maximus feugiat augue non accumsan. Pellentesque porta at ligula ac mollis.<label><input type="checkbox">add link</label></div>'+
    '<div>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam lobortis leo in cursus vehicula. Nam eget diam commodo, aliquam ante nec, imperdiet leo. Aliquam vestibulum turpis et orci laoreet cursus. Sed purus ipsum, venenatis convallis mi ac, finibus sagittis risus. Sed lobortis nisl in sapien aliquam, eu ullamcorper tellus condimentum. Vestibulum et urna ut nulla commodo sollicitudin ac nec mauris. Vestibulum sodales, neque vitae blandit finibus, sem nibh suscipit odio, non rhoncus nibh nulla sagittis sapien. Fusce pulvinar purus at ante scelerisque, in semper nibh venenatis. Vestibulum sed massa id massa blandit ornare eget vel elit. Mauris maximus feugiat augue non accumsan. Pellentesque porta at ligula ac mollis.<label><input type="checkbox">add link</label></div>'+
    '<div>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam lobortis leo in cursus vehicula. Nam eget diam commodo, aliquam ante nec, imperdiet leo. Aliquam vestibulum turpis et orci laoreet cursus. Sed purus ipsum, venenatis convallis mi ac, finibus sagittis risus. Sed lobortis nisl in sapien aliquam, eu ullamcorper tellus condimentum. Vestibulum et urna ut nulla commodo sollicitudin ac nec mauris. Vestibulum sodales, neque vitae blandit finibus, sem nibh suscipit odio, non rhoncus nibh nulla sagittis sapien. Fusce pulvinar purus at ante scelerisque, in semper nibh venenatis. Vestibulum sed massa id massa blandit ornare eget vel elit. Mauris maximus feugiat augue non accumsan. Pellentesque porta at ligula ac mollis.<label><input type="checkbox">add link</label></div>'
;

var dialog = document.createElement('dialog');

// START: document onReady
(function () {


  // fetch the explanationRequests and explanations
  explanationRequests = testExReqs;
  explanations = testExs;

  //insert dialog
  dialog.innerHTML = dialogHtml;
  dialog.id = "skiir-dialog";
  dialog.querySelector('#close').onclick = function (e) {
    dialog.close();
  };
  document.body.insertBefore(dialog, document.body.firstChild);

  $.ajax({
    url: "http://localhost:9000/articles/single",
    method: "GET",
    data: { "url": window.location.href }
  }).done(function(article){
    show(article.requests, article.annotations);
  }).fail(function(){
    console.log("Request failed", arguments);
  });
  
  show(explanationRequests, explanations);

})();

function show(requests, explanations){
  // update de DOM met buttons en explanation components
  // TODO: Bug! only 1 request per paragraph!
  requests.forEach(function(r){
    // search page for explanationRequest.original
    r.paragraph = getParagraphOfText(r.text_surroundings || r.original, r.text || r.phrase);
    r.phrase = r.text || r.phrase;
    // replace with button
    addExplanationRequest(r);
  });

  explanations.forEach(function(e){
    if(e.request_id){
      var req = requests.filter(function(r){ return r.id == e.request_id })[0];
      e.original = req && req.text_surroundings;
      e.phrase = r.text;
    }
    e.paragraph = getParagraphOfText(e.original);
    addExplanation(e);
  });
}

function addExplanation(ex) {

  var span = document.createElement('span');
  var button = document.createElement('button');
  button.textContent = ex.phrase;

  span.className = 'skiir-explanation';
  var links = '';
  if(ex.links) {
    links += '<div class="links">';
    for(var key in ex.links) {
      links += '<a href="'+ex.links[key]+'">['+key+']</a>';
    }
    links += '</div>';
  }
  var menu = '<div class="dropdown"><button>&#x2630;</button>'+
  '<ul><li><a href="#">Improve</a></li><li><a href="#">Downvote</a></li></ul></div>';


  span.innerHTML = '<div>' + menu + '<p>' + ex.explanation + '</p>' + links + '</div>';
  span.insertBefore(button, span.firstChild);
  button.onclick = function(e) {toggleShow(span);};

  try {

    var paragraph = ex.paragraph;
    var text = paragraph.innerHTML.split(ex.phrase);

    while (paragraph.firstChild) paragraph.removeChild(paragraph.firstChild);

    paragraph.appendChild(document.createTextNode(text[0]));
    paragraph.appendChild(span);
    paragraph.appendChild(document.createTextNode(text[1]));

  } catch(err){
    console.log(err);
  }
  span.querySelector('.dropdown button').onclick = function() {
    toggleShow(span.querySelector('ul'));
  };

  ex.span = span;

}

function toggleShow(span) {
  if(span.classList.contains('show')) {
    span.classList.remove('show');
  } else {
    span.classList.add('show');
  }
}

function addExplanationRequest(exReq) {
  var button = document.createElement('button');
  button.className = 'skiir-help';
  button.textContent = exReq.phrase;
  button.onclick = function() { openDialog(exReq) };

  try {

    var paragraph = exReq.paragraph;
    var text = paragraph.innerHTML.split(exReq.phrase);

    while (paragraph.firstChild) paragraph.removeChild(paragraph.firstChild);

    paragraph.appendChild(document.createTextNode(text[0]));
    paragraph.appendChild(button);
    paragraph.appendChild(document.createTextNode(text[1]));

  }
  catch(err){
    console.log(err);
  }
  exReq.button = button;
}

function updateExplanationRequest(exReq) {

  exReq.paragraph.innerHTML = exReq.paragraph.innerHTML.replace(exReq.button.outerHTML, exReq.phrase);

  delete exReq.button;

  addExplanation(exReq);
}

function openDialog(exReq) {

    var highlight = '<span>'+exReq.phrase+'</span>';
    dialog.showModal();
    dialog.querySelector('h3').textContent = exReq.phrase;
    dialog.querySelector('p#context').innerHTML = exReq.original.replace(exReq.phrase, highlight);
    dialog.querySelector('div#snippets').innerHTML = dummySnippets;

  dialog.querySelector('#done').onclick = function (e) {
    exReq.explanation = dialog.querySelector('textarea').value;
    updateExplanationRequest(exReq);

        // TODO: send update to server
        postRequest('http://skiir.com/requests', exReq, null);

        console.info("Sending annotation to server", exReq.explanation);

    explanationRequests.filter(function (el) {
      return el.id !== exReq.id
    });
    explanations.push(exReq);

    dialog.close();
  };
}

function getParagraphOfText(surround, text) {
  var match = $("p:containsEscaped("+escape(surround)+") p:containsEscaped("+escape(text)+")");
  match = match.size() && match || $("p:containsEscaped("+escape(text)+")");
  return match.get(0);
}

function getSelectionParentElement() {
  var parentEl = null, sel;
  if (window.getSelection) {
    sel = window.getSelection();
    if (sel.rangeCount) {
      parentEl = sel.getRangeAt(0).commonAncestorContainer;
      if (parentEl.nodeType != 1) {
        parentEl = parentEl.parentNode;
      }
    }
  } else if ((sel = document.selection) && sel.type != "Control") {
    parentEl = sel.createRange().parentElement();
  }
  return parentEl;
}

// Message handler (from background.js)
chrome.runtime.onMessage.addListener(function(req, sender, sendResponse) {

    // handle right click text selection requests
    if(req.details) {
        var exReq = req.details;

        exReq.paragraph = getSelectionParentElement();
        exReq.original = exReq.paragraph.textContent;


    //TODO: send data to popup.js (through background.js?)
    $.ajax({
      url: "http://localhost:9000/requests",
      method: "POST",
      data: {
        "article_url": window.location.href,
        "article_title": document.title,
        "article_text": document.body.innerText,
        "request_text": exReq.phrase,
        "request_text_surroundings": exReq.paragraph.innerText

      },
      complete: function(){
        // TODO: give feedback to user (checkmark overlay/anything)
        console.log("Saved at server");
      }
    });

    console.debug("Send annotation request to server", exReq);
    sendResponse({farewell: "goodbye"});
  }
});
