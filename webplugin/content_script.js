// Test Url:
// http://www.bloomberg.com/news/articles/2015-03-15/germans-tired-of-greek-demands-want-country-to-exit-euro

var testExReqs = [
    {
        id: 1,
        original:'Mueller’s sentiment is shared by a majority of Germans. A poll published March 13 by public broadcaster ZDF found 52 percent of his countrymen no longer want Greece to remain in Europe’s common currency, up from 41 percent last month. The shift is due to a view held by 80 percent of Germans that Greece’s government “isn’t behaving seriously toward its European partners.” ',
        phrase:'Mueller’s sentiment'
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
        explanation: "52% of Germans want Greece out of Euro, tire of its “arrogance”"
    },
    {
        id: 3,
        original:'The hardening of German opinion is significant because the country is the biggest contributor to Greece’s 240 billion-euro ($253 billion) twin bailouts and the chief proponent of budget cuts and reforms in return for aid. Tensions have been escalating between the two governments since Prime Minister Alexis Tsipras took office in January, promising to end an austerity drive that he blames on Chancellor Angela Merkel.',
        phrase: 'Tsipras took office in January',
        explanation: 'Alexis Tsipras, leader of the (extreme) left Syriza party, was sworn in Monday January 26, 2015 as Greek prime minister, setting the stage for a showdown with creditors over painful budget cuts and tax increases that could have potential ripple effects across the European Union.'
    }
]






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




function addExplanation(exReq) {
    var html = '<span class="skiir-exReqplanation">'+exReq.phrase+'<div>'+exReq.exReqplanation+'</div></span>';
    if(!exReq.paragraph) return console.warn("Are you running a test?");
    replaceSelection(html);
}

function addExplanationRequest(exReq) {
    var button = document.createElement('button');
    button.className = 'skiir-help';
    button.textContent = exReq.phrase;
    button.onclick = function(e) { openDialog( exReq ); };

    if(!exReq.paragraph) return console.warn("Are you running a test?");
    replaceSelection(button);
}

function updateExplanationRequest(exReq) {
    var button = exReq.paragraph.querySelector('.skiir-help');
    if(!exReq.paragraph) return console.warn("Are you running a test?");
    addExplanation(exReq);
}

function openDialog(exReq) {
    dialog.showModal();
    dialog.querySelector('h3').textContent = exReq.phrase;

    dialog.querySelector('#done').onclick = function(e) {
        exReq.explanation = dialog.querySelector('textarea').value;;
        updateExplanationRequest(exReq);

        // TODO: send update to serve
        console.info("Sending annotation to server", exReq.explanation);

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

/**
 * Replace current selection with HTML
 * Kudo's to: http://stackoverflow.com/questions/5393922/javascript-replace-selection-all-browsers
 */
function replaceSelection(html, selectInserted) {
    var sel, range, fragment;

    if (typeof window.getSelection != "undefined") {
        // IE 9 and other non-IE browsers
        sel = window.getSelection();

        // Test that the Selection object contains at least one Range
        if (sel.getRangeAt && sel.rangeCount) {
            // Get the first Range (only Firefox supports more than one)
            range = window.getSelection().getRangeAt(0);
            range.deleteContents();

            // Create a DocumentFragment to insert and populate it with HTML
            // Need to test for the existence of range.createContextualFragment
            // because it's non-standard and IE 9 does not support it
            if (typeof html.nodeType != 'undefined'){
                fragment = document.createDocumentFragment();
                fragment.appendChild(html);
            } else
            if (range.createContextualFragment) {
                fragment = range.createContextualFragment(html);
            } else {
                // In IE 9 we need to use innerHTML of a temporary element
                var div = document.createElement("div"), child;
                div.innerHTML = html;
                fragment = document.createDocumentFragment();
                while ( (child = div.firstChild) ) {
                    fragment.appendChild(child);
                }
            }
            var firstInsertedNode = fragment.firstChild;
            var lastInsertedNode = fragment.lastChild;
            range.insertNode(fragment);
            if (selectInserted) {
                if (firstInsertedNode) {
                    range.setStartBefore(firstInsertedNode);
                    range.setEndAfter(lastInsertedNode);
                }
                sel.removeAllRanges();
                sel.addRange(range);
            }
        }
    } else if (document.selection && document.selection.type != "Control") {
        // IE 8 and below
        range = document.selection.createRange();
        range.pasteHTML(html && html.innerHTML || html);
    }
}

function ajax(url,method,callback,body) {
    var call = new XMLHttpRequest();
    call.onreadystatechange=function() {if(call.readyState==4) callback(call.responseText);}
    call.open(method,url,true);
    call.send(body || null);
}

// Message handler (from background.js)
chrome.runtime.onMessage.addListener(function(req, sender, sendResponse) {

    // handle right click text selection requests
    if(req.details) {
        var exReq = req.details;

        exReq.paragraph = getSelectionParentElement();

        addExplanationRequest(exReq);

        //TODO: send data to popup.js (through background.js?)
        ajax("http://localhost:9000/requests", "POST", function(){
            // TODO: give feedback to user (checkmark overlay/anything)
            console.log("Saved at server");
        }, JSON.stringify({
            "article_url": window.location.href,
            "article_title": document.title,
            "article_text": document.body.innerText,
            "request_text": exReq.phrase,
            "request_text_surroundings": exReq.paragraph.innerText
        }));

        console.debug("Send annotation request to server", exReq);
    }
});