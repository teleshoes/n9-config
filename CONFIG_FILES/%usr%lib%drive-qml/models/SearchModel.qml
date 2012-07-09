import QtQuick 1.1
import MapsPlugin 1.0
import "../utils/Units.js" as Units
import "../utils/Zoom.js" as Zoom
import "../utils/AJAX.js" as Ajax
import "../components/components.js" as Components
import "../utils/SearchResults.js" as SearchResults
import "ModelFactory.js" as ModelFactory

Item {
    id: finder
    property int resultsCount: 20
    property int searchRadio: 20000
    property int didYouMeanCount: 0

    property int noError: 0
    property int networkConnectionError: 1
    property int userCancelledError: 2
    property int timedOutError: 3

    property int timeoutInterval: 30000 // 30 seconds

    property variant positioningModel
    property variant favoritesModel

    property bool suggestionsCancelled: false
    property bool cancelled: false
    property string searchServer: "http://where.mobile.mos.svc.ovi.com"
    property string chinaSearchServer: "http://where.mobile.china.mos.svc.ovi.com"
    property variant categoryMapping
    property variant invertedCountries: ["USA", "CAN", "NZL", "IND", "GBR", "AUS", "IRL", "FRA", "LKA"]

    signal onlineSearchDone(int errorCode, variant onlineResults)
    signal suggestionsDone(int errorCode, variant onlineResults)
    signal offlineSearchDone(int errorCode, variant onlineResults)
    signal searchDone(int errorCode, variant onlineResults)
    signal reverseGeocodingDone(int errorCode, variant results)

    Timer {
        id: timeoutTimer
        interval: timeoutInterval
        onTriggered: onlineSearchDone(timedOutError, [])
    }

    GeoCoordinates {
        id: searchCenter
    }

    Finder {
        id: searchFinder
    }

    function positionToName(coords) {
        searchFinder.searchResult.connect(finderReverseGeoCodingDone);
        var retval = searchFinder.reverseGeoCode(Finder.SEARCH_TYPE_OFFLINE, coords);
    }

    function getSuggestions(searchString, location) {
        var url = getSuggestionsUrl(searchString, location),
        client = Ajax.getSuggestionClient();

        client.onreadystatechange = function() {
            if (client.readyState == XMLHttpRequest.DONE) {
                var errorCode = noError,
                    suggestions = eval(client.responseText);

                if (client.status == 0) {
                    errorCode = suggestionsCancelled ? userCancelledError : networkConnectionError;
                }

                suggestionsDone(errorCode, suggestions);
            }
        };

        suggestionsCancelled = false;

        try {
            client.open("GET", url);
            client.send();
        } catch (err) {
            suggestionsDone(networkConnectionError, [])
        }
    }

    function search(searchString, location, online) {
        online ? searchOnline(searchString, location) : searchOffline(searchString, location);
    }

    function getSearchUrl(searchString, location) {
        var language = MapsPlugin.language ? MapsPlugin.language + "-" + countryCode : "eng-uk",
            serverAddress = device.chineseArea ? chinaSearchServer : searchServer;

        searchCenter.latitude = location.latitude;
        searchCenter.longitude = location.longitude;

        return serverAddress + "/NOSe/json?vi=where&re=1&la=" + language + "&dv=oviMaps&to=10&of=0"
                + "&lat=" + location.latitude + "&lon=" + location.longitude + "&q=" + searchString;
    }

    function getSuggestionsUrl(searchString, location) {
        return getSearchUrl(searchString, location) + "&lh=1";
    }

    function mapLocationInfoToSearchResult(locationinfo) {
        switch (locationinfo) {
            case Location.ADDR_COUNTRY_CODE: return "addrCountryName";
            case Location.ADDR_COUNTRY_NAME: return "addrCountryName";
            case Location.ADDR_PROVINCE_NAME: return "addrStateName";
            case Location.ADDR_COUNTY_NAME: return "addrTownshipName";
            case Location.ADDR_CITY_NAME: return "addrCityName";
            case Location.ADDR_DISTRICT_NAME: return "addrDistrictName";
            case Location.ADDR_POSTAL_CODE: return "addrPostalCode";
            case Location.ADDR_STREET_NAME: return "addrStreetName";
            case Location.ADDR_HOUSE_NUMBER: return "addrHouseNumber";
            case Location.PLACE_NAME: return "addrStreetName";
            case Location.PLACE_CATEGORY: return "categoryName";
            case Location.PLACE_PREMIUM_NODE_ID: return "placesId"
            default: return "";
        }
    }

    function searchOffline(searchString, location) {
        //location is destroyed
        searchCenter.latitude = location.latitude;
        searchCenter.longitude = location.longitude;

        searchFinder.searchResult.connect(onOfflineSearchDone);
        searchFinder.placeGeoCode(searchString, "ALL", Finder.PLACE_SEARCH_WHERE,
                location, searchRadio, resultsCount, false, didYouMeanCount);
    }

    function onOfflineSearchDone(error) {
        searchFinder.searchResult.disconnect(onOfflineSearchDone);

        SearchResults.results = finderResultToWebResult();
        offlineSearchDone(error, SearchResults.results);
        }

    function finderReverseGeoCodingDone(error)
    {
        var interestingLocationInfo = [
            Location.ADDR_HOUSE_NUMBER,
            Location.ADDR_STREET_NAME,
            Location.ADDR_POSTAL_CODE,
            Location.ADDR_DISTRICT_NAME,
            Location.ADDR_CITY_NAME,
            Location.ADDR_COUNTY_NAME,
            Location.ADDR_PROVINCE_NAME,
            Location.ADDR_COUNTRY_NAME,
            Location.ADDR_COUNTRY_CODE,
            Location.PLACE_NAME,
        ];

        SearchResults.reverseResults = [];
        var results = searchFinder.results;

        for (var i = 0, length = results.length; i < length; i++)
        {
            var result = results[i];
            var  properties = {};

            //populate properties
            var fieldKey;
            for (var j = 0; j < interestingLocationInfo.length; j++) {
                var locationInfo = interestingLocationInfo[j];
                if (result.hasField(locationInfo)) {
                    fieldKey = mapLocationInfoToSearchResult(locationInfo);
                    properties[fieldKey] = result.getField(locationInfo);
                }
            }
            var geoCoordinates = result.geoCoordinates;
            properties["geoDistance"] = geoCoordinates.distance(searchCenter);
            properties["geoLatitude"] = geoCoordinates.latitude;
            properties["geoLongitude"] = geoCoordinates.longitude;
            properties["type"] = result.hasField(Location.ADDR_STREET_NAME) ||
                                        result.hasField(Location.PLACE_NAME) ? "Street" :
                                        result.hasField(Location.ADDR_CITY_NAME) ? "City" : "Country";
            var country = properties["addrCountryName"];
            properties["addrCountryName"] = country ? qsTrId("qtn_drive_country_" + country) : "";
            var categoryId = (result.hasField(Location.PLACE_CATEGORY_ID) ? result.getField(Location.PLACE_CATEGORY_ID) : "-1");
            var res = parseSearchResult(categoryId, properties);
            SearchResults.reverseResults.push(res);
         }

        searchFinder.searchResult.disconnect(finderReverseGeoCodingDone);
        searchDone(error, SearchResults.reverseResults);
    }

    function finderResultToWebResult() {

        var interestingLocationInfo = [
            Location.ADDR_HOUSE_NUMBER,
            Location.ADDR_STREET_NAME,
            Location.ADDR_POSTAL_CODE,
            Location.ADDR_DISTRICT_NAME,
            Location.ADDR_CITY_NAME,
            Location.ADDR_COUNTY_NAME,
            Location.ADDR_PROVINCE_NAME,
            Location.ADDR_COUNTRY_NAME,
            Location.ADDR_COUNTRY_CODE,
            Location.PLACE_NAME
        ];

        var results = searchFinder.results,
            result = null,
            properties = null,
            locationInfo = 0,
            geoCoordinates = null,
            categoryId,
            webResults = [];

        for (var i = 0, length = results.length; i < length; i++) {
            result = results[i];
            properties = {};

            //populate properties
            var fieldKey;
            for (var j = 0; j < interestingLocationInfo.length; j++) {
                locationInfo = interestingLocationInfo[j];
                if (result.hasField(locationInfo)) {
                    fieldKey = mapLocationInfoToSearchResult(locationInfo);
                    properties[fieldKey] = result.getField(locationInfo);
                }
            }

            //set geocoords & simplified type determination
            geoCoordinates = result.geoCoordinates;
            properties["geoLatitude"] = geoCoordinates.latitude;
            properties["geoLongitude"] = geoCoordinates.longitude;
            properties["type"] = result.hasField(Location.ADDR_STREET_NAME) ||
                                        result.hasField(Location.PLACE_NAME) ? "Street" :
                                        result.hasField(Location.ADDR_CITY_NAME) ? "City" : "Country";
            categoryId = (result.hasField(Location.PLACE_CATEGORY_ID) ? result.getField(Location.PLACE_CATEGORY_ID) : "0");
            properties["addrCountryCode"] = properties["addrCountryName"];
            properties["addrCountryName"] = getLocalizedCountryName(properties["addrCountryName"]);

            //add to model
            webResults.push(parseSearchResult(categoryId, properties));
        }

        return webResults;
    }

    function getLocalizedCountryName(countryCode) {
        return countryCode ? qsTrId("qtn_drive_country_" + countryCode) : "";
    }

    function searchOnline(searchString, location) {
        var url = getSearchUrl(searchString, location),
            client = Ajax.getSearchClient();

        console.log("Searching online with URL: " + url);

        cancelled = false;
        SearchResults.results = [];

        client.onreadystatechange = function() {
            if (client.readyState == XMLHttpRequest.DONE && timeoutTimer.running) {
                timeoutTimer.stop();
                requestDoneHandler.call(this, client.status, client.responseText);
            }
        };

        try {
            client.open("GET", url);
            client.send();
            timeoutTimer.start();
        } catch (err) {
            onlineSearchDone(networkConnectionError, []);
        }
    }

    function requestDoneHandler(status, responseText) {
        var errorCode = noError;

        if (status == 200) {
            var response = eval("(" + responseText + ")"),
                results = response.results,
                len = results.length, i, result;

            SearchResults.results = [];

            for (i = 0; i < len; i++) {
                result = results[i];
                SearchResults.results.push(parseSearchResult(result.categories[0].id, result.properties));
            }

        } else if (status == 0) {
            errorCode = cancelled ? userCancelledError : networkConnectionError;
        }

        onlineSearchDone(errorCode, SearchResults.results);
    }

    //concat an array and take into account empty string, not nulls and undefineds
    function concat() {
        var strs = [], temp;
        for (var i = 0, il = arguments.length; i < il; i++) {
            temp = arguments[i] || "";
            if (temp && typeof temp == "string") {
                temp = temp.replace((/(?:^[\,\ ]*|[\,\ ]*$)/g), "").trim();
                if (temp) strs.push(temp);
            }
        }
        return strs.join(", ");
    }

    function parseSearchResult(iconId, item) {
        var address1 = "", address2 = "", address3 = "", label = "", detailAddress2 = "",
            detailAddress3 = "",  zoomLevels = Zoom.levels, zoomLevel = zoomLevels.street,
            type = item["type"];

        //Patch Taiwan case
        if (item["addrCountryCode"] == "TWN" && device.chineseArea) {
            item["addrCountryName"] = "Taiwan, province of China";
        }

        //Parse
        if (type == "Street") {
            address1 = buildStreetHouseNumberLine(address1, item["addrStreetName"], item["addrHouseNumber"],
                    item["addrCountryCode"]);
            if (item["addrCityName"] === item["addrDistrictName"]) {
                detailAddress2 = concat(item["addrPostalCode"], item["addrCityName"]);
                detailAddress3 = concat("", item["addrCountryName"]);
            } else {
                detailAddress2 = concat(item["addrDistrictName"], item["addrPostalCode"]);
                detailAddress3 = concat(item["addrCityName"], item["addrCountryName"]);
            }
            address2 = concat(detailAddress2, detailAddress3);
            zoomLevel = zoomLevels.street;

        } else if(type == "Township" || type == "City") {
            address1 = concat(item["addrCityName"], item["addrTownshipName"]);
            address2 = concat(item["addrStateName"], item["addrCountryName"]);
            detailAddress2 = address2;
            zoomLevel = zoomLevels.city;

        } else if (type == "Country") {
            item["addrCountryName"] && (address1 += item["addrCountryName"]);
            zoomLevel = zoomLevels.country;

        } else {
            item["title"] && (address1 = item["title"]);
            address2 = buildStreetHouseNumberLine(address2, item["addrStreetName"], item["addrHouseNumber"],
                    item["addrCountryCode"]);
            address2 = concat(address2, item["addrPostalCode"]);
            detailAddress2 = address2;
            detailAddress3 = concat(item["addrCityName"], item["addrCountryName"]);
            address2 = concat(detailAddress2, detailAddress3);
            (type === "State") && (zoomLevel = zoomLevels.state); // else stay default
        }

        var coords = positioningModel.createGeoCoordinates({latitude: item["geoLatitude"],
                                                            longitude: item["geoLongitude"]});

        item["geoDistance"] = coords.distance(searchCenter);

//        console.log("geoDistance: from (" + coords.latitude + ", " + coords.longitude + ") to (" +
//                    searchCenter.latitude + ", " + searchCenter.longitude + ") : " + item["geoDistance"]);

        var distance = Units.getReadableDistanceVisual(item["geoDistance"]);

        var placeId = item["placesId"];

        var favoriteKey = favoritesModel.getFavoriteKey(placeId,
                                                       {latitude: item["geoLatitude"],
                                                        longitude: item["geoLongitude"]});

        var isTheFavorite = (favoriteKey !== undefined);

        var iconUrlFav = getIconSourceFromId(iconId, "list", true);
        var iconUrlNoFav = getIconSourceFromId(iconId, "list", false);

        item["categoryName"] = getCategoryName(iconId);

        //console.log("Category name: " + item["categoryName"]);
        //console.log("PLACE_ID: " + placeId + ", IS FAVORITE? "+ isTheFavorite);

        return {
            label: label,
            address1: address1,
            address2: address2,
            detailAddress2: detailAddress2,
            detailAddress3: detailAddress3,
            distance: distance.value + distance.unit,
            location: {
                latitude: item["geoLatitude"],
                longitude: item["geoLongitude"]
            },
            zoomScale: zoomLevel,
            iconUrlList: isTheFavorite ? iconUrlFav : iconUrlNoFav,
            iconUrlFav: iconUrlFav,
            iconUrlNoFav: iconUrlNoFav,
            iconUrlMap:  getIconSourceFromId(iconId, "map", isTheFavorite),
            properties: item,
            favoriteKey: favoriteKey,
            isFavorite: isTheFavorite,
            placeId: placeId,
            iconId: -1
        }
    }

    function isInvertedCountry(countryCode) {
        return (invertedCountries.indexOf(countryCode) != -1);
    }

    function buildStreetHouseNumberLine(buildString, streetName, houseNumber, countryCode) {
        if (isInvertedCountry(countryCode)) {
            houseNumber && (buildString += houseNumber);
            streetName && (buildString += (" " + streetName));
        } else {
            streetName && (buildString += streetName);
            houseNumber && (buildString += (" " + houseNumber));
        }

        return buildString;
    }

    function getIconSourceFromId(categoryNumber, kind, isFavorite) {
        categoryNumber = parseInt(categoryNumber);
        var imageUrl = isFavorite ? Components.defaultCategoryMapIconUrlFav : Components.defaultCategoryMapIconUrl;

        // default prefix is map
        var prefix = "map_";
        if (kind == "list") {
            prefix = "list_";
            imageUrl = isFavorite ? Components.defaultCategoryListIconUrlFav : Components.defaultCategoryListIconUrl;
        }

        if (categoryNumber >= 9000000) {
            categoryNumber -= 9000000;
        }

        for (var i in categoryMapping) {
            if (categoryMapping.hasOwnProperty(i) && categoryMapping[i].categories.indexOf(categoryNumber) > -1) {
                imageUrl =  "../resources/categories/mobile_" + prefix + categoryMapping[i].id + (isFavorite ? "_fav" : "")+ ".png";
                break;
            }
        }

        return imageUrl;
    }

    function getCategoryName(categoryNumber) {
        categoryNumber = parseInt(categoryNumber);

        if (categoryNumber >= 9000000) {
            categoryNumber -= 9000000;
        }

        for (var i in categoryMapping) {
            if (categoryMapping.hasOwnProperty(i) && categoryMapping[i].categories.indexOf(categoryNumber) > -1) {
                var name = categoryMapping[i].id;
                return name.replace("_","-");
            }
        }

        return "";
    }

    function cancelSuggestions() {
        suggestionsCancelled = true;
        Ajax.getSuggestionClient().abort();
    }

    function cancelSearch() {
        cancelled = true;
        searchFinder.cancel();
        Ajax.getSearchClient().abort();
    }

    function reverseGeocode(location, online) {
        var searchType = online ? Finder.SEARCH_TYPE_ONLINE : Finder.SEARCH_TYPE_OFFLINE;
        searchCenter.latitude = location.latitude;
        searchCenter.longitude = location.longitude;

        searchFinder.searchResult.connect(onReverseGeocodingDone);
        searchFinder.reverseGeoCode(searchType, searchCenter);
        reverseGeoCodeTimer.restart();
    }

    Timer {
        id: reverseGeoCodeTimer
        interval: timeoutInterval  // 30 seconds
        onTriggered: onReverseGeocodingDone(timedOutError)  // integer 3
    }

    function onReverseGeocodingDone(errorCode) {
        reverseGeoCodeTimer.stop();
        searchFinder.searchResult.disconnect(onReverseGeocodingDone);
        if (errorCode === timedOutError) {
            console.log("--> ReverseGeoCoding Time Out. Result sets to undefined.");
            reverseGeocodingDone(errorCode, undefined);  //emit signal
        } else {
            var results = finderResultToWebResult();
            console.log("--> ReverseGeoCoding results count:", results.length);
            reverseGeocodingDone(errorCode, results[0]);  //emit signal
        }
    }

    Component.onCompleted: {
        onlineSearchDone.connect(searchDone);
        offlineSearchDone.connect(searchDone);
        categoryMapping = {
            "131": { id: "eat_drink", categories: [22, 33, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 179, 199, 238 ]},
            "132": { id: "goingout", categories: [3, 4, 6, 9, 15,26, 178, 181, 182, 203, 237 ]},
            "133": { id: "sights_museums", categories: [14, 18,27, 147, 150, 153, 158, 163, 183, 184, 185, 211, 213, 236 ]},
            "134": { id: "transport", categories: [0, 35, 41, 43, 42, 57, 58, 59, 216, 235 ]},
            "135": { id: "accomodation", categories: [32, 38, 170, 171, 172, 173, 174, 234 ]},
            "136": { id: "shopping", categories: [23, 24, 49, 60, 119, 142, 143, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 205, 225, 233 ]},
            "137": { id: "business_services", categories: [2, 17, 19, 20, 28, 40, 46, 47, 48, 51, 52, 54, 55, 56, 112, 113, 114, 115, 118, 122, 137, 180, 206, 208, 210, 215, 217, 218, 219, 232 ]},
            "138": { id: "facility", categories: [ 8, 11, 12, 16, 25, 29, 34, 36, 37, 39, 106, 109, 111, 128, 131, 132, 133, 136, 156, 159, 160, 164, 168, 169, 175, 176, 177, 186, 187, 200, 201, 202, 204, 214, 224, 231 ]},
            "139": { id: "leisure", categories: [ 1, 13, 21, 30, 48, 162, 188, 230 ]},
// NO ICON FOR THIS "140": { id: "administrative_areas_buildings", categories: [104, 105, 116, 117, 207, 220, 221, 226, 229 ]},
            "141": { id: "natural_geographical", categories: [44, 45, 50, 161, 222, 223, 225, 228 ]}
        };

        positioningModel = ModelFactory.getModel("PositioningModel");
        favoritesModel = ModelFactory.getModel("FavoritesModel");
    }
}
