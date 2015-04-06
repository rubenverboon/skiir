var baseUrl = 'http://127.0.0.1:9000'; // enter IP

var annotations = [], actions, dialog;

// START of the program: document onReady
(function () {

  // build and insert the dialog
  dialog = buildDialog();
  document.body.insertBefore(dialog, document.body.firstChild);

  // get requests and annotations from the server and add them to the dom
  $.getJSON(baseUrl + '/articles/single', {url: window.location.href}).done(function(article) {
    actions = article.links;
    annotations = article.annotations;
    insertRequestsAndAnnotations(article.requests);
  });
})();

/**
 * Builds a skeleton for the dialog and returns it.
 *
 * <dialog>
 *   <h3>
 *   <button>close
 *   <p>context
 *   <div>
 *     <textarea>
 *     <button>done
 *   <h3>
 *   <div>related articles
 *   <h3>
 *   <div>annotations
 *
 *   @returns {HTMLElement} Dialog
 */
function buildDialog() {

  return createElement('dialog', {id: 'skiir-dialog'}, [
    createElement('h3', {textContent: 'Please explain this'}),
    createElement('button', {
      id: 'close', innerHTML: '&#x2716;', onclick: function () {
        dialog.close()
      }
    }),
    createElement('p', {id: 'context'}),
    createElement('div', {className: 'row'}, [
      createElement('textarea', {
        className: "skiir-button-prefix",
        placeholder: "Please explain the underlined text above"
      }),
      createElement('button', {id: 'done', className: 'skiir-button', textContent: 'Done'})
    ]),
    createElement('h3', {className: 'skiir-dialog-title', textContent: 'Pick your sources:'}),
    createElement('div', {id: 'relatedArticles'}),
    createElement('h3', {className: 'skiir-dialog-title', textContent: 'Or vote for one of these explanations:'}),
    createElement('div', {id: 'annotations'})
  ]);
}

/**
 * Initially updates the DOM with buttons from Request objects
 *
 * @param requests A list of Requests
 */
function insertRequestsAndAnnotations(requests) {
  // TODO: Bug! only 1 request per paragraph!
  requests.forEach(function (req) {

    req.paragraph = _getParagraphOfText(req.text_surroundings, req.text);

    var annotation = getBestAnnotation(req);
    if(annotation) {

      insertAnnotationElement(req, annotation);
    }
    // otherwise, insert a regular Request
    else {
      insertRequestElement(req);
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
function insertAnnotationElement(req, annotation) {

  var span = createElement('span', {
    className: 'skiir-explanation'
  });

  var button = createElement('button', {
    textContent: req.text,
    onclick: function () {
      _toggleShow(span);
    }
  });

  var divChildren = [
    // <button>Improve
    createElement('button', {
      textContent: 'Improve',
      className: 'skiir-button skiir-button-green improve',
      onclick: function () {
        openDialog(req);
      }
    }),
    // <p>answer
    createElement('p', {textContent: annotation.answer})
  ];

  if (annotation.references) {

    divChildren.push(createElement('div', {className: 'links'},
      annotation.references.map(function(ref, idx) {
        return createElement('a', {href:ref, textContent: '['+idx+']'})
      })
   ));
  }

  var div = createElement('div', {className: "skiir-explanation-box"},
    divChildren
  );

  span.appendChild(button);
  span.appendChild(div);

  replaceTextInParagraphWithElement(req.text, req.paragraph, span);

  req.htmlElement = span;
}

/**
 * Inserts a Request button into the DOM with the following markup:
 *
 * <button>phrase
 *
 * @param req Explanation Request object
 */
function insertRequestElement(req) {

  var button = createElement('button', {
    className: 'skiir-help',
    textContent: req.text,
    onclick: function () {
      openDialog(req)
    }
  });

  replaceTextInParagraphWithElement(req.text, req.paragraph, button);

  req.htmlElement = button;
}

/**
 * Replaces the Request htmlElement with the best Annotation.
 *
 * @param req Request object
 */
function upgradeAnnotationElement(req) {

  var annotation = getBestAnnotation(req);

  if(!annotation)
    return;

  // remove current element from paragraph
  req.paragraph.innerHTML = req.paragraph.innerHTML.replace(req.htmlElement.outerHTML, req.text);

  delete req.htmlElement;

  insertAnnotationElement(req, annotation);
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

/**
 * Opens the dialog, fleshes out the skeleton with the request text, snippets, and existing annotations.
 *
 * @param req Request
 */
function openDialog(req) {

  dialog.showModal();

  // builds the paragraph with the requested text highlighted
  _buildContextParagraphIn(dialog.querySelector('p#context'), req);

  // get related articles for snippets
  $.getJSON(baseUrl + req.actions.relatedArticles)
  .done(function (data) {
    _buildSnippetsIn(dialog.querySelector('div#relatedArticles'), data);
  });

  // build annotations with vote buttons
  _buildAnnotationsIn(dialog.querySelector('div#annotations'), req);

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

    console.info("Sending annotation to server", textarea.value);
    $.ajax({
      url: baseUrl + req.actions.annotate,
      data: JSON.stringify({
        explanation: textarea.value,
        references: references
      }),
      contentType: 'application/json',
      method: 'POST'
    }).done(function (data) {

      $.getJSON(baseUrl + data.actions.siblings).done(function(data2) {
        // add the last (newest) explanation to annotations
        annotations.push(data2.slice(-1)[0]);
        upgradeAnnotationElement(req);
      });

      console.info('Posted annotation.')
    });

    textarea.value = "";

    dialog.close();
  };
}

/**
 * Fills the [contextElement] with highlighted text from the [req]
 * @param contextElement ParagraphElement
 * @param req Request
 * @private
 */
function _buildContextParagraphIn(contextElement, req) {

  contextElement.innerHTML = req.text_surroundings;

  var highlight = createElement('span', {
    id: 'exReqText',
    textContent: req.text
  });

  replaceTextInParagraphWithElement(req.text, contextElement, highlight);

  $("#exReqText").scrollView();
}

/**
 * Adds snippets with checkboxes to the [snippetsElement] in the following format:
 *
 * <div class="row">
 *   <label>
 *     <input>
 *   <div>
 *     <a>
 *       <h4> article title
 *       <p>snippet
 *
 * @param snippetsElement
 * @param snippetData
 * @private
 */
function _buildSnippetsIn(snippetsElement, snippetData) {
  snippetsElement.innerHTML = '';
  snippetData.forEach(function(s) {
    snippetsElement.appendChild(createElement('div', {className: 'row'}, [
        createElement('label', {}, [
          createElement('input', {type:'checkbox', value: s.url})
        ]),
        createElement('div', {}, [
          createElement('a', {href: s.url, target: '_blank'}, [
            createElement('h4', {textContent: s.title.toUpperCase()}),
            createElement('p', {innerHTML: s.snippets.map(_stringify).reduce(function (a, b) {
                    return a + b
                  }, "")}
            )
          ])
        ])
      ]
    ))
  });
}

/**
 * Adds Annotations with vote buttons to the [annotationElement]
 *
 * <div>
 *   <div>votes
 *   <button>
 *   <span>answer
 *
 * @param annotationsElement
 * @param req
 * @private
 */
function _buildAnnotationsIn(annotationsElement, req) {
  annotationsElement.innerHTML = '';

  var reqAnnotations = annotations.filter(function (i) {
    return req.id === i.request_id
  });
  reqAnnotations.sort(function (a, b) {
    return b.votes - a.votes
  });

  reqAnnotations.forEach(function (annotation) {

    annotation.voteButton = createElement('button', {
      className: 'skiir-button vote',
      textContent: 'Vote',
      onclick: function() {
        vote(annotation, req);
      }
    });

    var rowDiv = createElement('div', {className: 'row'}, [
      createElement('div', {className: 'skiir-button-prefix votes', textContent: annotation.votes}),
      annotation.voteButton,
      createElement('span', {textContent: annotation.answer})
    ]);

    annotationsElement.appendChild(rowDiv);
  });
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
    upgradeAnnotationElement(req);
  });
}


// Adds a Request after right-clicking:
chrome.runtime.onMessage.addListener(function (req, sender, sendResponse) {
  if (req.details) {
    var exReq = req.details;
    console.debug("Send annotation request to server", exReq);

    var postbody = {
      "article_url": window.location.href,
      "article_title": document.title,
      "article_text": document.querySelector('.article-body').textContent,
      "request_text": exReq.text,
      "request_text_surroundings": _getParagraphOfSelection().textContent
    };
    var paragraph = _getParagraphOfSelection();

    $.ajax({
      url: baseUrl + "/requests",
      data: JSON.stringify(postbody),
      contentType: 'application/json',
      method: 'POST'
    }).done(function (data) {
      // The request was saved, now display annotation request:
      $.getJSON(baseUrl + data.actions.self).done(function (exReq) {
        exReq.paragraph = paragraph;
        insertRequestElement(exReq);
        //openDialog(exReq);
      });
    });
  }
});



////////////////////////////////////
//         Utilities              //
// The functions below are boring //
////////////////////////////////////

/**
 * Helper function to create and return an Html Element
 * @param name
 * @param [properties]
 * @param [children]
 * @returns {HTMLElement}
 */
function createElement(name, properties, children) {
  var element = document.createElement(name);

  if(properties)
    for(var key in properties) {
      element[key] = properties[key];
    }

  if(children)
    children.forEach(function(child) {
      element.appendChild(child);
    });

  return element;
}

/**
 * Adds or removes a 'show' class
 * @param span
 * @private
 */
function _toggleShow(span) {
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
 * @private
 */
function _stringify(snip) {
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

/**
 *
 * @param text_surroundings Text of a paragraph that surrounds the `text`
 * @param text The selected phrase within a paragraph
 * @returns {*} Paragraph HtmlElement
 * @private
 */
function _getParagraphOfText(text_surroundings, text) {
  var match = $("p:containsEscaped(" + escape(text_surroundings) + ") p:containsEscaped(" + escape(text) + ")");
  match = match.size() && match || $("p:containsEscaped(" + escape(text) + ")");
  return match.get(0);
}

/**
 * @returns {*} Paragraph HtmlElement of a mouse selection.
 * @private
 */
function _getParagraphOfSelection() {
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
