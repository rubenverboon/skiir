// Test Url:
// http://www.bloomberg.com/news/articles/2015-03-15/germans-tired-of-greek-demands-want-country-to-exit-euro

var testExReqs = [
    {
        id: 1,
        original:'Mueller’s sentiment is shared by a majority of Germans. A poll published March 13 by public broadcaster ZDF found 52 percent of his countrymen no longer want Greece to remain in Europe’s common currency, up from 41 percent last month. The shift is due to a view held by 80 percent of Germans that Greece’s government “isn’t behaving seriously toward its European partners.” ',
        phrase:'Mueller’s sentiment'
    }
];

var testExs = [
    {
        id: 1,
        original:'“They’ve got a lot of hubris and arrogance, being in the situation they’re in and making all these demands,” said Mueller, 49, waiting for fares near the Brandenburg Gate. “Maybe it’s better for Greece to just leave the euro.”',
        phrase:'arrogance',
        explanation: "Like, being a cocky bitch"
    }
];

var explanationRequests = [], explanations = [];

var dialogHtml =
    '<h3></h3>'+
    '<textarea style="width: 426px; height: 87px;">write an explanation here</textarea>'+
    'Pick your reference'+
    '<iframe style="width:426px;" src="http://en.wikipedia.org/wiki/Greece"></iframe> </br></br>'+
    '<button id="done">Done</button>'+
    '<button id="close">Cancel</button>';

var dialog = document.createElement('dialog');

// START: document onReady
(function() {

    // fetch the explanationRequests and explanations
    explanationRequests = testExReqs;
    explanations = testExs;

    //insert dialog
    dialog.innerHTML = dialogHtml;
    dialog.id = "skiir-dialog";
    dialog.querySelector('#close').onclick = function(e) {dialog.close();};
    document.body.insertBefore(dialog, document.body.firstChild);

    // update de DOM met buttons en explanation components
    // TODO: Bug! only 1 request per paragraph!
    for(var idx in explanationRequests) {
        var exReq = explanationRequests[idx];

        // search page for explanationRequest.original
        exReq.paragraph = getParagraphOfText(exReq.original);

        // replace with button
        addExplanationRequest(exReq);
    }

    for(var idx in explanations) {
        var explanation = explanations[idx];

        explanation.paragraph = getParagraphOfText(explanation.original);

        addExplanation(explanation);
    }

})();




function addExplanation(ex) {
    var html = '<span class="skiir-explanation">'+ex.phrase+'<div>'+ex.explanation+'</div></span>';
    ex.paragraph.innerHTML = ex.paragraph.innerHTML.replace(ex.phrase, html);
}

function addExplanationRequest(exReq) {
    var button = document.createElement('button');
    button.className = 'skiir-help';
    button.textContent = exReq.phrase;

    exReq.paragraph.innerHTML = exReq.paragraph.innerHTML.replace(exReq.phrase, button.outerHTML);

    exReq.paragraph.querySelector('.skiir-help').onclick = function(e) { openDialog( exReq ); };
}

function updateExplanationRequest(exReq) {
    var button = exReq.paragraph.querySelector('.skiir-help');
    exReq.paragraph.innerHTML = exReq.paragraph.innerHTML.replace(button.outerHTML, exReq.phrase);
    addExplanation(exReq);
}

function openDialog(exReq) {
    dialog.showModal();
    dialog.querySelector('h3').textContent = exReq.phrase;

    dialog.querySelector('#done').onclick = function(e) {
        exReq.explanation = dialog.querySelector('textarea').value;;
        updateExplanationRequest(exReq);

        // TODO: send update to serve

        explanationRequests.filter(function (el) {return el.id !== exReq.id});
        explanations.push(exReq);

        dialog.close();
    };
}

function getParagraphOfText(text) {
    var elements = document.querySelectorAll(".article-body p");

    for (var i = 0; i < elements.length; i++) {
        var el = elements[i];

        // TODO: BUG! deze check is niet netjes!!!
        if(el.textContent.split(' ')[0] == text.split(' ')[0]) {
            return el;
        }
    }
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
    } else if ( (sel = document.selection) && sel.type != "Control") {
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

        addExplanationRequest(exReq);

        //TODO: send data to the server and popup.js (through background.js?)
        //console.log(data);
    }
});