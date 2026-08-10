// Build a category cloud in the right margin sidebar for selected pages.
(function () {
  var MAX_CATEGORIES = 15;

  function clamp(v, min, max) {
    return Math.max(min, Math.min(max, v));
  }

  function parseCountText(text) {
    var match = String(text || "").match(/\((\d+)\)/);
    return match ? Number(match[1]) : 0;
  }

  function buildCloudFromCategories(doc) {
    var categories = [];
    var nodes = doc.querySelectorAll(".quarto-listing-category .category");

    nodes.forEach(function (node) {
      var labelNode = node.childNodes[0];
      var label = (labelNode && labelNode.textContent ? labelNode.textContent : "").trim();
      var encoded = node.getAttribute("data-category") || "";
      var countNode = node.querySelector(".quarto-category-count");
      var count = parseCountText(countNode ? countNode.textContent : "");

      if (!label || !encoded || label.toLowerCase() === "all") {
        return;
      }

      categories.push({ label: label, encoded: encoded, count: count });
    });

    return categories;
  }

  function renderCloud(categories) {
    var margin = document.getElementById("quarto-margin-sidebar");
    if (!margin || !categories.length) {
      return;
    }

    var existing = document.getElementById("category-cloud-box");
    if (existing) {
      existing.remove();
    }

    var sorted = categories.slice().sort(function (a, b) {
      return b.count - a.count || a.label.localeCompare(b.label);
    });

    sorted = sorted.slice(0, MAX_CATEGORIES);

    var maxCount = sorted[0].count;
    var minCount = sorted[sorted.length - 1].count;
    var span = Math.max(1, maxCount - minCount);

    var box = document.createElement("section");
    box.id = "category-cloud-box";
    box.className = "category-cloud-box";

    var title = document.createElement("h5");
    title.className = "category-cloud-title";
    title.textContent = "Category Cloud";
    box.appendChild(title);

    var cloud = document.createElement("div");
    cloud.className = "category-cloud";

    sorted.forEach(function (item) {
      var size = 0.82 + ((item.count - minCount) / span) * 0.78;
      size = clamp(size, 0.82, 1.6);

      var a = document.createElement("a");
      a.className = "category-chip";
      a.href = "./CCC.html#category=" + encodeURIComponent(item.encoded);
      a.textContent = item.label;
      a.title = item.label + " (" + item.count + ")";
      a.style.fontSize = size.toFixed(2) + "rem";

      var count = document.createElement("span");
      count.className = "chip-count";
      count.textContent = "(" + item.count + ")";
      a.appendChild(count);

      cloud.appendChild(a);
    });

    box.appendChild(cloud);
    margin.appendChild(box);
  }

  function initCategoryCloud() {
    var path = window.location.pathname || "";
    var page = path.split("/").pop();
    if (page === "") {
      page = "index.html";
    }

    if (!["index.html", "blog.html", "CCC.html"].includes(page)) {
      return;
    }

    fetch("./CCC.html", { cache: "no-store" })
      .then(function (resp) {
        if (!resp.ok) {
          throw new Error("Unable to load CCC page for category cloud.");
        }
        return resp.text();
      })
      .then(function (html) {
        var parser = new DOMParser();
        var doc = parser.parseFromString(html, "text/html");
        var categories = buildCloudFromCategories(doc);
        renderCloud(categories);
      })
      .catch(function () {
        // Fail silently if cloud data cannot be loaded.
      });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initCategoryCloud);
  } else {
    initCategoryCloud();
  }
})();
