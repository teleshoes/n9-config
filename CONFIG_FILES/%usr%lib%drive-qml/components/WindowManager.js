var pages = [];
var currentPage = null;

function pushHidden(page, params) {
    if (window.busy) return;
    window.busy = true;

    var newPage = createPage(page, params);

    pageContainer.page1 = newPage;
    pageContainer.state = newPage.fullscreen ? "page-fullscreen" : "page";

    window.busy = false;

    currentPage = newPage;
    pages.push(newPage);
}

function push(page, params, noAnimation) {
    if (window.busy) return;
    window.busy = true;

    var newPage = createPage(page, params);

    if (pages.length > 0 && !noAnimation) {
        switchPages(currentPage, newPage, "left");
    } else {
        newPage.beforeShow(true);

        pageContainer.page1 = newPage;
        pageContainer.state = newPage.fullscreen ? "page-fullscreen" : "page";

        pageContainer.actionBar.updateButtons(newPage);
        newPage.scrollableList && newPage.scrollableList.updateScrollButtons();

        newPage.show(true);
        window.busy = false;
    }

    currentPage = newPage;
    pages.push(newPage);
}

function replace(page, params) {
    if (window.busy) return;
    window.busy = true;

    var newPage = createPage(page, params);

    if (pages.length > 1) {
        switchPages(pages.pop(), newPage, "left");
    }

    currentPage = newPage;
    pages.push(newPage);
}

function pop(tagName) {
    if (pages.length < 2) return;
    if (window.busy) return;
    window.busy = true;

    currentPage = pages.pop();

    if (tagName) {
        var tagIndex, index, page;

        for(tagIndex = pages.length-1; tagIndex; tagIndex--) {
            if(tagName === pages[tagIndex].tag) break;
        }
        if (tagIndex < 0) return;

        for(var index = pages.length-1; index > tagIndex; index--) {
            page = pages.pop();
            page.beforeDestroy();
            page.destroy();
        }
    }

    var prevPage = pages[pages.length - 1];
    switchPages(prevPage, currentPage, "right");
    currentPage = prevPage;
}

function deletePages(fromTag, toTag) {
    var fromTagIndex, toTagIndex, index, page;

    // find to index
    if (toTag) {
        for(toTagIndex = pages.length-1; toTagIndex; toTagIndex--) {
            if(toTag === pages[toTagIndex].tag) break;
        }
    } else {
        toTagIndex = pages.length-1;
    }

    // find from index
    for(fromTagIndex = toTagIndex-1; fromTagIndex; fromTagIndex--) {
        if(fromTag === pages[fromTagIndex].tag) break;
    }

    // silent error handling
    if (toTagIndex === 0 || fromTagIndex < 0) return;

    // delete pages in reverse order
    for(var index = toTagIndex-1; index > fromTagIndex; index--) {
        page = pages[index];
        page.beforeDestroy();
        page.destroy();
    }
    pages.splice(fromTagIndex + 1, toTagIndex - fromTagIndex - 1);
}

function deleteToFirstPage() {
    if (pages.length < 2) return;

    pageContainer.page1 = pages[0];
    pageContainer.state = pages[0].fullscreen ? "page-fullscreen" : "page";
    pageContainer.page2 = null;

    var index = pages.length - 1, page;

    // hide current page
    pages[index].beforeHide();
    pages[index].hide();

    for(; index > 0; index--) {
        page = pages[index];
        page.beforeDestroy();
        page.destroy();
        pages.pop();
    }
}

function showDialog(type, options) {
    var component = Qt.createComponent("Dialog" + type + ".qml");
    var newDialog = component.createObject(window, {options: options});
    newDialog.z = 9;
    return newDialog;
}

function openUrl(link) {
    if (device.online) {
        Qt.openUrlExternally(link);
    } else {
        var dialog = window.showDialog("", {
            text: qsTrId("qtn_drive_go_online_open_internet_page_dlg")
        });

        dialog.userReplied.connect(function(answer) {
            if (answer == "ok") Qt.openUrlExternally(link);
        });
    }
}

function switchPages(page1, page2, direction) {
    pageContainer.page1 = page1;
    pageContainer.page2 = page2;

    pageContainer.state = direction === "right" ? "prepareSlideRight" : "prepareSlideLeft";
    pageContainer.state = direction === "right" ? "slideRight" : "slideLeft";
}

function createPage(page, params) {
    var component, newPage;

    component = (typeof page === "string") ? Qt.createComponent(resolvePageUrl(page)) : page;
    if (component.status == Component.Error)
        console.log("Error loading page " + component.url + ", error: " + component.errorString());

    if (component.status == Component.Error) {
        console.log("Component: " + component.url + ", Error: " + component.errorString());
    }

    newPage = component.createObject(pageContainer);
    newPage.params = params ? params : {};
    newPage.create();
    return newPage;
}

function resolvePageUrl(page) {
    return "../views/" + page;
}
