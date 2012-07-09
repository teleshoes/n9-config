.pragma library

// Just a place holder for XMLHttpRequest object
// because we can't store it on a property

var searchClient = new XMLHttpRequest();
var suggestionClient = new XMLHttpRequest();
var client = new XMLHttpRequest();

function getClient() {
    return client;
}

function getSearchClient() {
    return searchClient;
}

function getSuggestionClient() {
    return suggestionClient;
}
