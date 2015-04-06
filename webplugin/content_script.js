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

    var exs = annotations.filter(function (a) {
      return req.id === a.request_id
    });

    // if request has annotations, insert an Annotion into the DOM
    if (exs.length) {
      // get the explanation with the most votes
      req.explanation = exs.reduce(function (prev, curr) {
        return curr.votes > prev.votes ? curr : prev;
      });

      insertAnnotation(req);
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
 * @param req Request with it's best Annotation
 */
function insertAnnotation(req) {

  var span = document.createElement('span');
  span.className = 'skiir-explanation';

  var button = document.createElement('button');
  button.textContent = req.text;
  button.onclick = function () {
    toggleShow(span);
  };

  var links = '';
  if (req.explanation.references) {
    links += '<div class="links">';
    for (var key in req.explanation.references) {
      links += '<a href="' + req.explanation.references[key] + '">[' + key + ']</a>';
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
  div.innerHTML = '<p>' + req.explanation.answer + '</p>' + links;
  div.insertBefore(improveButton, div.firstChild);

  span.appendChild(button);
  span.appendChild(div);

  replaceTextInParagraphWith(req.text, req.paragraph, span);

  req.span = span;
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

  replaceTextInParagraphWith(req.text, req.paragraph, button);

  req.button = button;
}

/**
 * Replaces a Request button with an Annotation.
 *
 * @param req Request object
 */
function upgradeRequestToAnnotation(req) {

  var exs = annotations.filter(function (i) {
    return req.id === i.request_id
  });

  if (exs.length) {
    // get the explanation with the most votes
    req.explanation = exs.reduce(function (prev, curr) {
      return curr.votes > prev.votes ? curr : prev;
    });

    req.paragraph.innerHTML = req.paragraph.innerHTML.replace(req.button.outerHTML, req.text);

    delete req.button;

    insertAnnotation(req);
  }
}


/**
 * Replaces a string within a paragraph with an html element
 * @param text
 * @param paragraph
 * @param element
 */
function replaceTextInParagraphWith(text, paragraph, element) {
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

  // get annotations for vote buttons
  $.getJSON(baseUrl + req.actions.annotations)
  .done(function (data) {
    var snippetsHtml = '<div id ="skiir-dialog-ol">';
    data.sort(function (a, b) {
      return b.votes - a.votes
    });
    data.forEach(function (s) {
      var vote_url = s.actions.vote;
      snippetsHtml +=
        '<div class="row"><div class="skiir-button-prefix votes">' + s.votes + '</div>' +
        '<button class="skiir-button vote" data-url="' + vote_url + '">Vote</button>' +
        '<span>' + s.answer + '</span></div>';
    });
    snippetsHtml += '</div>';
    dialog.querySelector('div#annotations').innerHTML = snippetsHtml;
  });

  // Vote button functionality
  $(dialog).off("click", "button.vote");
  $(dialog).on("click", "button.vote", function () {
    var b = $(this);
    $.post(baseUrl + b.attr('data-url'), null, function () {
      b.prev(".votes").text(1 + parseInt(b.prev(".votes").text()));
    });
  });

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

    httpPost(req.actions.annotate, postData, function (data) {

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
      'type': 'POST'
    }).done(function (data) {
      // The request was saved, now display annotation request:
      $.getJSON(baseUrl + data.actions.self).done(function (exReq) {
        exReq.paragraph = paragraph;
        insertRequest(exReq);
        //openDialog(exReq);
      });
    }).fail(function () {

    });
    sendResponse({farewell: "goodbye"});
  }
});



///////////////
// Utilities //
///////////////

function httpPost(url, data, callback) {
  var httpRequest = new XMLHttpRequest();
  httpRequest.open("POST", baseUrl + url, true);
  httpRequest.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
  httpRequest.send(JSON.stringify(data));

  if (callback)
    httpRequest.onloadend = function () {
      var json = null;
      try {
        json = JSON.parse(httpRequest.responseText);
      } catch(e) {}
      callback(json, httpRequest);
    };
}

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
