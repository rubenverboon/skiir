var baseUrl = 'http://127.0.0.1:9000'; // enter IP

var annotations = [], actions;

var dialog = document.createElement('dialog');

// START of the program: document onReady
(function () {
  insertDialog();

  // get requests and annotations from the server and add them to the dom
  $.getJSON(baseUrl + '/articles/single', {url: window.location.href}).done(function(article) {
    actions = article.links;
    annotations = article.annotations;
    insertRequestsAndAnnotations(article.requests);
  });
})();

function insertDialog() {
  dialog.innerHTML =
    '<h3>Please explain this</h3>' +
    '<button id="close">&#x2716;</button>' +
    '<p id="context"></p>' +
    '<div class="row">' +
    '<textarea class="skiir-button-prefix" placeholder="Please explain the underlined text above"></textarea>' +
    '<button id="done" class="skiir-button">Done</button>' +
    '</div>' +
    '<h3 class="skiir-dialog-title">Pick your sources:</h3>' +
    '<div id="relatedArticles"></div>' +
    '<h3 class="skiir-dialog-title">Or vote for one of these explanations:</h3>' +
    '<div id="annotations"></div>';
  dialog.id = "skiir-dialog";
  dialog.querySelector('#close').onclick = function (e) {
    dialog.close();
  };
  document.body.insertBefore(dialog, document.body.firstChild);
}

/**
 * Initially updates the DOM with buttons from Request objects
 *
 * @param requests A list of Requests
 */
function insertRequestsAndAnnotations(requests) {
  // TODO: Bug! only 1 request per paragraph!
  requests.forEach(function (req) {

    req.paragraph = getParagraphOfText(req.text_surroundings, req.text);

    var annotation = getBestAnnotation(req);
    if(annotation) {

      insertAnnotation(req, annotation);
    }
    // otherwise, insert a regular Request
    else {
      insertRequest(req);
    }
  });
}

/**
 * Inserts an Annotation into the DOM in the following markup:
 *
 * <span>
 *   <button>phrase
 *   <div>
 *     <button>improve
 *     <p>explanation
 *     *<a>references
 *
 * @param req The Request
 * @param annotation The Annotation of the request
 */
function insertAnnotation(req, annotation) {

  var span = document.createElement('span');
  span.className = 'skiir-explanation';

  var button = document.createElement('button');
  button.textContent = req.text;
  button.onclick = function () {
    toggleShow(span);
  };

  var links = '';
  if (annotation.references) {
    links += '<div class="links">';
    for (var key in annotation.references) {
      links += '<a href="' + annotation.references[key] + '">[' + key + ']</a>';
    }
    links += '</div>';
  }

  var improveButton = document.createElement('button');
  improveButton.textContent = 'Improve';
  improveButton.className = 'skiir-button skiir-button-green improve';
  improveButton.onclick = function () {
    openDialog(req);
  };

  var div = document.createElement('div');
  div.className = "skiir-explanation-box";
  div.innerHTML = '<p>' + annotation.answer + '</p>' + links;
  div.insertBefore(improveButton, div.firstChild);

  span.appendChild(button);
  span.appendChild(div);

  replaceTextInParagraphWithElement(req.text, req.paragraph, span);

  req.htmlElement = span;
}

/**
 * Inserts a Request button into the DOM.
 *
 * <button>phrase
 * @param req Explanation Request object
 */
function insertRequest(req) {

  var button = document.createElement('button');
  button.className = 'skiir-help';
  button.textContent = req.text;
  button.onclick = function () {
    openDialog(req)
  };

  replaceTextInParagraphWithElement(req.text, req.paragraph, button);

  req.htmlElement = button;
}

/**
 * Replaces a Request button with an Annotation.
 *
 * @param req Request object
 */
function upgradeRequestToAnnotation(req) {

  var annotation = getBestAnnotation(req);

  if(!annotation)
    return;

  // remove current element from paragraph
  req.paragraph.innerHTML = req.paragraph.innerHTML.replace(req.htmlElement.outerHTML, req.text);

  delete req.htmlElement;

  insertAnnotation(req, annotation);
}

/**
 * Gets the annotation with the highest vote.
 * @param req Request
 */
function getBestAnnotation(req) {
  var reqAnnotations = annotations.filter(function (i) {
    return req.id === i.request_id
  });
  if(!reqAnnotations.length)
    return null;

  return reqAnnotations.reduce(function (prev, curr) {
    return curr.votes > prev.votes ? curr : prev;
  });
}


/**
 * Replaces a string within a paragraph with an html element
 * @param text
 * @param paragraph
 * @param element
 */
function replaceTextInParagraphWithElement(text, paragraph, element) {
  try {

    var splittedText = paragraph.innerHTML.split(text);

    while (paragraph.firstChild) paragraph.removeChild(paragraph.firstChild);

    paragraph.insertAdjacentHTML('afterbegin', splittedText[0]);
    paragraph.appendChild(element);
    paragraph.insertAdjacentHTML('beforeend', splittedText[1]);

  } catch (err) {
    console.error(err);
  }
}

function toggleShow(span) {
  if (span.classList.contains('show')) {
    span.classList.remove('show');
  } else {
    span.classList.add('show');
  }
}

/**
 * Builds a snippet HTML string from a snippet
 * @param snip
 * @returns {*} HTML string
 */
function stringify(snip) {
  result = '';
  var bolds = snip.bolds[0];
  var start = snip.outer[0];
  var result = snip.snip;
  bolds.sort(function (a, b) {
    return b[1] - a[1]
  }).forEach(function (bold) {
    result = [result.slice(0, bold[1] - start), '</b>', result.slice(bold[1] - start)].join('');
    result = [result.slice(0, bold[0] - start), '<b>', result.slice(bold[0] - start)].join('');
  });
  if (start != 0) result = "..." + result;
  result += '...';

  return result;
}

function openDialog(req) {

  var highlight = '<span id="exReqText">' + req.text + '</span>';
  dialog.showModal();
  dialog.querySelector('p#context').innerHTML = req.text_surroundings.replace(req.text, highlight);
  $("#exReqText").scrollView();

  // get related articles for snippets
  $.getJSON(baseUrl + req.actions.relatedArticles)
  .done(function (data) {

    var snippetsHtml = '';
    data.forEach(function (s) {
      snippetsHtml +=
        '<div class="row">' +
        '<label><input type="checkbox" value="' + s.url + '"></label>' +
        '<div>' +
        '<a href="' + s.url + '">' +
        '<h4>' + s.title.toUpperCase() + '</h4>' +
        s.snippets.map(stringify).reduce(function (a, b) {
          return a + b
        }, "") +
        '</a></div>' +
        '</div>';
    });

    dialog.querySelector('div#relatedArticles').innerHTML = snippetsHtml;

  });

  var reqAnnotations = annotations.filter(function (i) {
    return req.id === i.request_id
  });

  reqAnnotations.sort(function (a, b) {
    return b.votes - a.votes
  });

  var snippets = document.createElement('div');
  snippets.id = 'skiir-dialog-ol';

  reqAnnotations.forEach(function (annotation) {

    annotation.voteButton = document.createElement('button');
    annotation.voteButton.className = 'skiir-button vote';
    annotation.voteButton.textContent = 'Vote';
    annotation.voteButton.onclick = function() {
      vote(annotation, req);
    };

    var rowDiv = document.createElement('div');
    rowDiv.className = 'row';

    rowDiv.insertAdjacentHTML('afterbegin', '<div class="skiir-button-prefix votes">' + annotation.votes + '</div>');
    rowDiv.appendChild(annotation.voteButton);
    rowDiv.insertAdjacentHTML('beforeend', '<span>' + annotation.answer + '</span>');

    snippets.appendChild(rowDiv);
  });

  dialog.querySelector('div#annotations').innerHTML = '';
  dialog.querySelector('div#annotations').appendChild(snippets);

  // Submitting of Annotation:
  dialog.querySelector('#done').onclick = function (e) {
    var textarea = dialog.querySelector('textarea');

    // Can't submit empty annotation
    if (!textarea.value)
      return;

    var references = [].map.call( // return all values from checked checkboxes
      dialog.querySelectorAll('[type="checkbox"]:checked'), function (obj) {
        return obj.value;
      });

    var postData = {
      explanation: textarea.value,
      references: references
    };
    console.info("Sending annotation to server", textarea.value);

    textarea.value = "";

    $.ajax({
      url: baseUrl + req.actions.annotate,
      data: JSON.stringify(postData),
      contentType: 'application/json',
      method: 'POST'
    }).done(function (data) {

      $.getJSON(baseUrl + data.actions.siblings).done(function(data2) {
        // add the last (newest explanation to annotations
        annotations.push(data2.slice(-1)[0]);
        upgradeRequestToAnnotation(req);
      });

      console.info('Posted annotation.')
    });

    dialog.close();
  };
}

/**
 * Votes for this Annotation for a specific Request
 * @param annotation
 * @param req
 */
function vote(annotation, req) {

  $.post(baseUrl + annotation.actions.vote, null, function () {
    annotation.votes += 1;
    annotation.voteButton.previousElementSibling.textContent = annotation.votes;
    upgradeRequestToAnnotation(req);
  });
}


/**
 *
 * @param text_surroundings Text of a paragraph that surrounds the `text`
 * @param text The selected phrase within a paragraph
 * @returns {*} Paragraph HtmlElement
 */
function getParagraphOfText(text_surroundings, text) {
  var match = $("p:containsEscaped(" + escape(text_surroundings) + ") p:containsEscaped(" + escape(text) + ")");
  match = match.size() && match || $("p:containsEscaped(" + escape(text) + ")");
  return match.get(0);
}

/**
 * @returns {*} Paragraph HtmlElement of a mouse selection.
 */
function getParagraphOfSelection() {
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

// Adding a Request via right-clicking:
chrome.runtime.onMessage.addListener(function (req, sender, sendResponse) {
  if (req.details) {
    var exReq = req.details;
    console.debug("Send annotation request to server", exReq);

    var postbody = {
      "article_url": window.location.href,
      "article_title": document.title,
      "article_text": document.querySelector('.article-body').textContent,
      "request_text": exReq.text,
      "request_text_surroundings": getParagraphOfSelection().textContent
    };
    var paragraph = getParagraphOfSelection();

    $.ajax({
      url: baseUrl + "/requests",
      data: JSON.stringify(postbody),
      contentType: 'application/json',
      method: 'POST'
    }).done(function (data) {
      // The request was saved, now display annotation request:
      $.getJSON(baseUrl + data.actions.self).done(function (exReq) {
        exReq.paragraph = paragraph;
        insertRequest(exReq);
        //openDialog(exReq);
      });
    });
  }
});



///////////////
// Utilities //
///////////////
$.extend($.expr[':'], {
  containsEscaped: function (el, index, m) {
    var s = unescape(m[3]).replace(/[\s\n]+/g, " ").trim();
    return $(el).text().replace(/[\s\n]+/g, " ").indexOf(s) >= 0;
  }
});

// scrollParent is from Jquery-UI
$.fn.scrollParent = function (includeHidden) {
  var position = this.css("position"),
    excludeStaticParent = position === "absolute",
    overflowRegex = includeHidden ? /(auto|scroll|hidden)/ : /(auto|scroll)/,
    scrollParent = this.parents().filter(function () {
      var parent = $(this);
      if (excludeStaticParent && parent.css("position") === "static") {
        return false;
      }
      return overflowRegex.test(parent.css("overflow") + parent.css("overflow-y") + parent.css("overflow-x"));
    }).eq(0);

  return position === "fixed" || !scrollParent.length ? $(this[0].ownerDocument || document) : scrollParent;
};
$.fn.scrollView = function (duration) {
  return this.each(function () {
    $($(this).scrollParent()).get(0).scrollTop = $(this).offset().top - $($(this).scrollParent()).offset().top;
  });
};
