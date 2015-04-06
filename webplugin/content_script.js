var baseUrl = 'http://127.0.0.1:9000'; // enter IP

var explanationRequests = [], explanations = [], actions;

var dialog = document.createElement('dialog');

// START: document onReady
(function () {
  //insert dialog
  insertDialog();

  // get requests and annotations from the server and add them to the dom
  httpGet("/articles/single", {url: window.location.href}, function (article) {
    actions = article.links;
    show(article.requests, article.annotations);
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

function show(requests, explanations) {
  // update de DOM met buttons en explanation components
  // TODO: Bug! only 1 request per paragraph!
  requests.forEach(function (exReq) {
    // search page for explanationRequest.text_surroundings

    exReq.paragraph = getParagraphOfText(exReq.text_surroundings, exReq.text);

    var exs = explanations.filter(function (i) {
      return exReq.id === i.request_id
    });

    if (exs.length) {
      // get the explanation with the most votes
      exReq.explanation = exs.reduce(function (prev, curr) {
        return curr.votes > prev.votes ? curr : prev;
      });
      addExplanation(exReq);
    }
    else {
      addExplanationRequest(exReq);
    }
  });
}

/**
 * <span>
 *   <button>phrase
 *   <div>
 *     <button>improve
 *     <p>explanation
 *     *<a>references
 *
 * @param ex Explanation
 */
function addExplanation(ex) {

  var span = document.createElement('span');
  var button = document.createElement('button');
  button.textContent = ex.text;

  span.className = 'skiir-explanation';
  var links = '';
  if (ex.explanation.references) {
    links += '<div class="links">';
    for (var key in ex.explanation.references) {
      links += '<a href="' + ex.explanation.references[key] + '">[' + key + ']</a>';
    }
    links += '</div>';
  }

  var improveButton = document.createElement('button');
  improveButton.textContent = 'Improve';
  improveButton.className = 'skiir-button skiir-button-green improve';
  improveButton.onclick = function () {
    openDialog(ex);
  };
  var div = document.createElement('div');
  div.className = "skiir-explanation-box"
  div.innerHTML = '<p>' + ex.explanation.answer + '</p>' + links;
  div.insertBefore(improveButton, div.firstChild);
  span.appendChild(button);
  span.appendChild(div);
  button.onclick = function () {
    toggleShow(span);
  };

  try {

    var paragraph = ex.paragraph;
    var text = paragraph.innerHTML.split(ex.text);

    while (paragraph.firstChild) paragraph.removeChild(paragraph.firstChild);

    paragraph.insertAdjacentHTML('afterbegin', text[0]);
    paragraph.appendChild(span);
    paragraph.insertAdjacentHTML('beforeend', text[1]);

  } catch (err) {
    console.error(err);
  }

  ex.span = span;
  explanations.push(ex);
}

function toggleShow(span) {
  if (span.classList.contains('show')) {
    span.classList.remove('show');
  } else {
    span.classList.add('show');
  }
}

/**
 * <button>phrase
 * @param exReq Explanation Request object
 */
function addExplanationRequest(exReq) {

  var button = document.createElement('button');
  button.className = 'skiir-help';
  button.textContent = exReq.text;
  button.onclick = function () {
    openDialog(exReq)
  };

  try {

    var paragraph = exReq.paragraph;
    var text = paragraph.innerHTML.split(exReq.text);

    while (paragraph.firstChild) paragraph.removeChild(paragraph.firstChild);

    paragraph.insertAdjacentHTML('afterbegin', text[0]);
    paragraph.appendChild(button);
    paragraph.insertAdjacentHTML('beforeend', text[1]);

  }
  catch (err) {
    console.error(err);
  }
  exReq.button = button;
  explanationRequests.push(exReq);
}

function updateExplanationRequest(exReq) {

  var exs = explanations.filter(function (i) {
    return exReq.id === i.request_id
  });

  if (exs.length) {
    // get the explanation with the most votes
    exReq.explanation = exs.reduce(function (prev, curr) {
      return curr.votes > prev.votes ? curr : prev;
    });

    exReq.paragraph.innerHTML = exReq.paragraph.innerHTML.replace(exReq.button.outerHTML, exReq.text);

    delete exReq.button;

    addExplanation(exReq);
  }
}

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

function openDialog(exReq) {

  var highlight = '<span id="exReqText">' + exReq.text + '</span>';
  dialog.showModal();
  dialog.querySelector('p#context').innerHTML = exReq.text_surroundings.replace(exReq.text, highlight);
  $("#exReqText").scrollView();

  // get related articles for snippets
  httpGet(exReq.actions.relatedArticles, null, function (data) {
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
  httpGet(exReq.actions.annotations, null, function (data) {
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

    httpPost(exReq.actions.annotate, postData, function (data) {

      $.getJSON(baseUrl + data.actions.annotation).done(function(data2) {
        // add the last (newest explanation to explanations
        explanations.push(data2.slice(-1)[0]);
        updateExplanationRequest(exReq);
      });

      console.info('Posted annotation.')
    });

    dialog.close();
  };
}

function getParagraphOfText(surround, text) {
  var match = $("p:containsEscaped(" + escape(surround) + ") p:containsEscaped(" + escape(text) + ")");
  match = match.size() && match || $("p:containsEscaped(" + escape(text) + ")");
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
      "request_text_surroundings": getSelectionParentElement().textContent
    };
    var paragraph = getSelectionParentElement();

    $.ajax({
      url: baseUrl + "/requests",
      data: JSON.stringify(postbody),
      contentType: 'application/json',
      'type': 'POST'
    }).done(function (data) {
      // The request was saved, now display annotation request:
      $.getJSON(baseUrl + data.actions.self).done(function (exReq) {
        exReq.paragraph = paragraph;
        addExplanationRequest(exReq);
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
function httpGet(url, params, callback) {

  function serialize(obj) {
    var str = [];
    for (var p in obj)
      if (obj.hasOwnProperty(p)) {
        str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
      }
    return str.join("&");
  }

  if (params) url += '?' + serialize(params);

  var httpRequest = new XMLHttpRequest();

  if (callback)
    httpRequest.onloadend = function () {
      callback(JSON.parse(httpRequest.responseText), httpRequest);
    };
  httpRequest.open('GET', baseUrl + url, true);
  httpRequest.send();

}

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
