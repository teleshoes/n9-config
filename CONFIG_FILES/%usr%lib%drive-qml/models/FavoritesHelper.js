// -*- mode: js; js-indent-level: 4; -*-

function _log (message, debug) {    
//    console.debug(message);
}

function initialize() {
    var init = function () {
        collectObjects();
    };

    _log('initialize called');

    if (share) {
        if (!share.collected) {
            if (share.init) {
                init();
            } else {
                share.initialized.connect(init);
            }
        }
    }
}

function createObject(uri) {
    if (!objectFactory) {
        objectFactory = Qt.createComponent("Favorite.qml");
    }
    var object = objectFactory.createObject(favoritesModel);

    //object.uri = uri;
    return object;
}

function collectObjects(callback) {
    if (!share) return;

    var store = share.syncStore,
        criteria = store.createCriteria(),
        results, favorite, object;

    callback = callback || function () {};
    criteria.appendClass('location');

    store.searchDone.connect(function() {
        results = store.lastResults;
        JS.objects = {}; // purge objects
        for (var i = 0, l = results.length; i < l; i++) {
            object = results[i];
            favorite = favoriteFromStoreObject(object);

            if (favorite) {
                JS.objects[favorite.key] = favorite;

            }
        }

        share.collected = true;
        callback(true);
    });
    store.search(criteria, store.createSorting(), JS.maxResults);
}

function formatAddress(properties) {
    var line = (properties.addrStreetName || "") + " "  + (properties.addrHouseNumber || "");
    var line2 = (properties.addrPostalCode || "") + " " + (properties.addrCityName || "");
    if (line != " " && line2 != " ") {
        line += ", " + line2;
    }
    if (line === " ") line = line2;
    return line;
}

function favoriteFromStoreObject(storeObject, favorite) {
    _log('favoriteFromStoreObject');

    var favorite = favorite || createObject(uriCount++),
        metadata = storeObject.getMetadata(),
        mapsLocation = storeObject.getMapsProperties(),
        position, latitude, longitude;

    favorite.storeObjectProperties = extractStoreObjectProperties(storeObject);
    position = favorite.storeObjectProperties.position;

    if (position) {
        latitude = position.latitude;
        longitude = position.longitude;
    }

    if (favorite.storeObjectProperties.placeId) {
        _log('Going to restore object from place ID');
        favorite.key = favorite.storeObjectProperties.placeId;
    } else if (latitude !== undefined && longitude !== undefined) {
        _log('Going to restore object from fuzzy location ['+latitude+'] ['+longitude+']');
        favorite.key = 'fuzzy-'+latitude+','+longitude;
        favorite.isFuzzy = true;
    } else {
        _log('Favorite cannot be restored without Place ID or latitude+longitude');
        return null;
    }

    favorite.storeObject = storeObject;
    favorite.syncId = storeObject.LID;
    favorite.text = metadata.getName();
    favorite.description = metadata.getDescription();
    favorite.categories = storeObject.getPlaceCategories() || [];
    favorite.modificationDate = storeObject.getModificationDate();
    return favorite;
}

function extractStoreObjectProperties(storeObject) {
    _log('extractStoreObjectProperties');

    var metadata = storeObject.getMetadata(),
        position = storeObject.getPosition(),
        address = storeObject.getAddress(),
        contact = storeObject.getContact(),
        mapsLocation = storeObject.getMapsProperties(),
        properties = {};

    if (position) {
        properties.position = {
            latitude: position.getLatitude(),
            longitude: position.getLongitude()
        };

        _log('Position is extracted' + position.getLatitude() + ', ' + position.getLongitude());
    } else {
        properties.position = {};

        _log('Position is empty');
    }

    if (address) {
        properties.address = {
            city: address.getField(address.CITY),
            countryCode: address.getField(address.COUNTRY_CODE),
            country: address.getField(address.COUNTRY),
            streetNumber: address.getField(address.STREET_NUMBER),
            postalCode: address.getField(address.POSTAL_CODE),
            street: address.getField(address.STREET)
        };
    } else {
        properties.address = {};
    }

    _log('Extracted street ' + properties.address.street);

    if (contact) {
        properties.contact = {
            phone: contact.getField(contact.PHONE),
            email: contact.getField(contact.EMAIL),
            web: contact.getField(contact.WEB)
        };
    } else {
        properties.contact = {};
    }

    if (mapsLocation) {
        properties.placeId = mapsLocation.getBasePlaceID();
    }

    properties.isPublicTransport = customKey(storeObject, 'isPublicTransport') === 'true';
    _log('Extracted pt state as ' + (properties.isPublicTransport ? 'truthy' : 'falsy'));

    return properties;
}

function getIconPath(category, mode) {
    return  "resources/categories/mobile_" +
            (mode === "map"? "map" : "list") +
            "_"+ (category ? category : "address") + "_fav.png";
}

function getTypeFromCategory(categories) {
    if (!categories) {
        return null;
    }

    var name;

    if(categories[0]) {
        name = categories[0];
    }

    return getCategoryTypeByName(name);
}

function getCategoryTypeByName(name) {
    if(name && name !== "") {
        name = name.toLowerCase();

        var categoryMapping = {
            "131": {id:"eat-drink",  names: ["restaurant", "bar-pub", "coffee-tea", "snacks-fast-food","eat-drink","food-drink"]},
            "132": {id:"goingout", names: ["theatre-music-culture","casino","cinema","dance-night-club","going-out"]},
            "133": {id:"sights-museums", names:["landmark-attraction","museum","sights-museums"]},
            "134": {id:"transport", names: ["airport", "car-dealer-repair", "car-rental","ferry-terminal","petrol-station","public-transport","railway-station","taxi-stand","transport"]},
            "135": {id:"accomodation", names: ["accommodation","hostel","hotel","motel"]},
            "136": {id:"shopping", names: ["bookshop","clothing-accessories-shop","department-store","electronics-shop","hardware-house-garden-shop","kiosk-convenience-store","mall","shop","shopping","sport-outdoor-shop"]},
            "137": {id:"business-services", names: ["atm-bank-exchange", "business-services", "business-industry","pharmacy","police-emergency","post-office","religious-place","service","tourist-information","travel-agency"]},
            "138": {id:"facility", names: ["building","communication-media","education-facility","facilities","facility","fair-convention-facility","government-community-facility","hospital-health-care-facility","outdoor-area-complex","parking-facility","sports-facility-venue"]},
            "139": {id:"leisure", names: ["amusement-holiday-park", "camping","leisure-outdoor","recreation"]},
            "140": {id:"areas-infrastructure", names:["administrative-region","library"]},
            "141": {id: "nature-geography",names:["body-of-water","city-town-village","forest-heath-vegetation","mountain-hill","undersea-feature"]}
        }

        for (var i in categoryMapping) {
            if (categoryMapping.hasOwnProperty(i)) {
                if ((categoryMapping[i].names.indexOf(name) >-1) || (categoryMapping[i].id == name)) {
                    return categoryMapping[i].id.replace("-","_");
                }
            }
        }
    }
    return null;
}

function getCategoryTypeById(categoryNumber) {
    if (categoryNumber<9000000) {
        return getIconFromMosCategoryMapping(categoryNumber);
    }
    if (typeof categoryNumber != "object") {
        categoryNumber -= 9000000;
        var categoryMapping = {
            "131": {id:"eat-drink", categories:[22,33,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,179,199,238]},
            "132": {id:"goingout", categories:[3,4,6,9,15,26,178,181,182,203,237]},
            "133": {id:"sights-museums", categories:[14,18,27,147,150,153,158,163,183,184,185,211,213,236]},
            "134": {id:"transport", categories:[0,35,41,43,42,57,58,59,216,235]},
            "135": {id:"accomodation", categories:[32,38,170,171,172,173,174,234]},
            "136": {id:"shopping", categories:[23,24,49,60,119,142,143,189,190,191,192,193,194,195,196,197,198,205,225,233]},
            "137": {id:"business-services", categories:[2,17,19,20,28,40,46,47,48,51,52,54,55,56,112,113,114,115,118,122,137,180,206,208,210,215,217,218,219,232]},
            "138": {id:"facility", categories:[8,11,12,16,25,29,34,36,37,39,106,109,111,128,131,132,133,136,156,159,160,164,168,169,175,176,177,186,187,200,201,202,204,214,224,231]},
            "139": {id:"leisure", categories:[1,13,21,30,48,162,188,230]},
            "140": {id:"areas-infrastructure", categories:[104,105,116,117,207,220,221,226,229]},
            "141": {id: "nature-geography",categories: [44, 45, 50, 161, 222, 223, 225, 228]}
        }

        for (var i in categoryMapping) if (categoryMapping.hasOwnProperty(i)){
            if (categoryMapping[i].categories.indexOf(categoryNumber)>-1){
                return categoryMapping[i].id.replace("-","_");
            }
        }
    }
    return null;
}

function getIconFromMosCategoryMapping(category){
    category=parseInt(category,10);
    var categoryMapping = {
        "eat-drink":[
            0x16,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0x5b,0x5c,0x5d,0x5e,0x5f,0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x3d,0x3e,0x40,0xc7,0x21,0xb3,0x3f,0x113
            ],
        "goingout":[0xcb,0x4,0x6,0x9,0xf,0x1a,0xb2,0xb5,0xb6,0x3],
        "sights-museums":[0x1b,0x93,0x94,0x95,0x96,0x99,0xa3,0xb8,0xd3,0xd5,0xe,0x12,0x9e,0xb7,0xb9,0x111],
        "transport":[0x0,0x2b,0x29,0x2a,0x39,0x3a,0x3b,0xdd,0xde,0xdf,0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe6,0xe7,0xe8,0xe9,0xea,0xeb,0xec,0xed,0xee,0xef,0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc,0xfd,0xfe,0xff,0x100,0x101,0x23,0xd8,0x110],
        "accomodation":[0x26,0xaa,0xab,0xac,0xae,0x10f,0xad,0x20],
        "shopping":[0xc5,0x17,0x10e,0x18,0xbd,0x3c,0x77,0x8f,0xbe,0x114,0x31,0xc3,0xc4,0xc2,0xc6,0xc0,0xc1,0xcd,0xbf,0x8e,0x108],
        "business-services":[0x2f,0x7a,0x10d,0x28,0x70,0x72,0x73,0x13,0x1c,0x11,0x36,0xd2,0x14,0x34,0x2,0x2e,0x33,0x38,0xb4,0x115,0x116,0x5,0xce,0x37,0x76,0x89,0xcf,0xd0,0xd7,0x102],
        "facility":[0x25,0x71,0x84,0x85,0x88,0xc8,0x8,0xc,0x22,0x24,0x80,0x83,0x9c,0xb0,0xc9,0x1d,0x6a,0x6d,0x6f,0x1f,0x7,0xa,0x10,0x27,0xdb,0x15,0xcc,0xb,0x19,0x9f,0xa0,0xa4,0xa8,0xa9,0xaf,0xb1,0xba,0xbb,0xca,0xd6,0xdc,0x105,0x10c],
        "leisure":[0x30,0x1,0xd,0x1e,0xa2,0xbc,0x10b],
        "areas-infrastructure":[0x117,0x74,0x11b,0x68,0x69,0x75,0x107,0x118,0x10a],
        "nature-geography":[0x32,0xa1,0x106,0x2c,0x2d,0x104,0x103,0x109]
    }
    for (var i in categoryMapping) if (categoryMapping.hasOwnProperty(i)){
        if (categoryMapping[i].indexOf(category)>-1){
            return i.replace("-","_");
        }
    }
    return null;
}


function getPlaceSubtitle(object) {
    if(object.publictransport && object.publictransport.lines) {
        var str = "", lines = object.publictransport.lines;
        for(var i=0; i< lines.length; i++) {
            str += lines[i].officialName + ((i < lines.length-1) ? ", " : "");
        }
        return str;
    }
    return formatAddress(object.properties) || formatAddress(returnExist(object,"details","location","address"));
}

function customKey (location, key, value) {
    if (value !== undefined) {
        location.setCustomKey(syncShareKey, key, value);
    } else {
        return location.getCustomKey(syncShareKey, key);
    }
}

function getFormattedAddress(favorite) {
    _log("getFormattedAddress");

    var address = favorite.storeObjectProperties.address;

    function concat(by, one, two) {
        if (!one && !two) return "";
        if (one && two)
            return [one, two].join(by);
        else
            return one ? one : two;
    }

    if(address) {
        var line1, line2; // Should equal to detailAddress2, detailAddress3
        var streetName = concat(" ", address.street, address.streetNumber);
        if (streetName == favorite.text) streetName = "";
        line1 = concat(", ", streetName, address.postalCode);
        line2 = concat(", ", address.city, address.country);
        if (line1 && !streetName) {
            line1 = concat(" ", line1, address.city);
            line2 = address.country || "";
        }

        // return a collection contains address2(full address), detailAddress2, and detailAddress3
        return [concat(', ', line1, line2), line1, line2];
    }
    else {
        return null;
    }
}

function rename(name, favoriteKey) {
    _log("rename favorite with key " + favoriteKey +" to '" + name + "'");

    if (!share) return;


    if(! JS.objects.hasOwnProperty(favoriteKey)) {
        _log("No favorite found with key "+ favoriteKey);
        return;
    }

    var favorite = JS.objects[favoriteKey];
    favorite.text = name;

    var object = favorite.storeObject;
    var metadata = object.getMetadata();
    metadata.setName(name);
    object.setMetadata(metadata);

    var store = share.syncStore;
    store.updateObject(object);

    favorite.storeObject = object;

    _log("Rename complete.");

    // TODO: emit some signal to update views
}

function remove(favoriteKey) {
    _log("deleting favorite with key " + favoriteKey);

    if (!share) return;

    if(! JS.objects.hasOwnProperty(favoriteKey)) {
        _log("No favorite found with key "+ favoriteKey);
        return;
    }

    var object = JS.objects[favoriteKey];

    var store = share.syncStore;

    if (object.syncId === 0) {
        //TODO: Do we need this?!
        var obj = JS.objects[object.key];
        if (obj) {
            object.syncId = obj.syncId;
        }
    }

    if (object.syncId != 0 && store.removeObjectById(object.syncId, false)) {
        if (JS.objects.hasOwnProperty(object.key)) {
            delete JS.objects[object.key];
        }

        if (favoritesModel) {
            favoritesModel.favoriteRemoved(object);
        }
    }
}

function removeAll() {
    _log("deleting all favorites");

    for (var index in JS.objects) {
        var favorite = JS.objects[index];

        remove(favorite.key);
    }

}

function addFavorite(name, searchPosition, searchResult)
{
    _log("adding new favorite: " + name + ", (" + searchPosition.latitude + ", " + searchPosition.longitude + ")");

    if (!share) return;

    var store = share.syncStore,
        mapsLocation = share.createMapsLocationProperties(),
        position = share.createPosition(), metadata = share.createMetadata(),
        address = share.createAddress(), contact = share.createContact(),
        locationObj = null;


    locationObj = share.createLocationObject();

    mapsLocation.setMapsAppVersion("4.0.32");
    mapsLocation.setMapContentVersion("0.2.43.117");

    if (searchResult.properties["placesId"]) {
        var placeId = searchResult.properties["placesId"];

        _log('Setting placeId to [' + placeId + ']');

        mapsLocation.setBasePOI(placeId, 1);
    } else {
        _log('No placeId, location will be considered fuzzy');
    }

    position.setCoordinates(searchPosition.latitude || 0, searchPosition.longitude || 0);

    address.setField(address.CITY, searchResult.properties["addrCityName"] || '');
    address.setField(address.STREET, searchResult.properties["addrStreetName"]  || '');
    address.setField(address.STREET_NUMBER, searchResult.properties["addrHouseNumber"]  || '');
    address.setField(address.POSTAL_CODE, searchResult.properties["addrPostalCode"]  || '');
    address.setField(address.COUNTRY, searchResult.properties["addrCountryName"] || '');
    address.setField(address.COUNTRY_CODE, searchResult.properties["addrCountryName"]  || '');

    contact.setField(contact.PHONE, '');
    contact.setField(contact.EMAIL, '');
    contact.setField(contact.WEB, '');

    metadata.setName(name);
    metadata.setDescription(name);

    var categories = [];

    var categoryName = searchResult.properties["categoryName"] || '';

    console.log("Adding favorite from category: " + categoryName);
    categories.push(categoryName);

    locationObj.setMapsProperties(mapsLocation);
    locationObj.setPosition(position);
    locationObj.setMetadata(metadata);
    locationObj.setAddress(address);
    locationObj.setContact(contact);
    locationObj.setPlaceCategories(categories);

    store.addObject(locationObj);

    if (favoritesModel) {
        var fav = favoriteFromStoreObject(locationObj);

        _log('created favorite for place id ['+fav.key+']');
        JS.objects[fav.key] = fav;

        favoritesModel.favoriteAdded(fav);

        return fav.key;
    }
}

function getFavoriteKey(placeId, location)
{
    _log("getFavoriteKey: " + placeId + ", (" + location.latitude + ", " + location.longitude + ")");

    for (var index in JS.objects) {
        var favorite = JS.objects[index];

        if(placeId) {
            var favPlaceId = favorite.storeObjectProperties.placeId;

            _log("compare with: " + favPlaceId);

            if(placeId === favPlaceId) {
                _log("Favorite location found by place id! " + index)
                return index;
            }
        }
        else {
            var favPosition = favorite.storeObjectProperties.position;

            _log("compare with: (" + favPosition.latitude + ", " + favPosition.longitude + ")");

            var latDiff = Math.abs(location.latitude - favPosition.latitude);
            var lonDiff = Math.abs(location.longitude - favPosition.longitude);

            var accuracy = 0.00005;

            if(latDiff < accuracy && lonDiff < accuracy) {
                _log("Favorite location found by position! " + index)
                return index;
            }
        }
    }    

    return undefined;
}


function synchronizeFavorites(callback, progressCallback)
{
    if (!share) return;

    var sync_status = 0;
    var service = share.syncService,
        sso = ModelFactory.getModel("SSOManager"),
        sync, pro;

    if (service) {
        if (sso.token) {
            service.setOption(service.OPTION_TOKEN, sso.token);
            service.setOption(service.OPTION_USER, '');
            service.setOption(service.OPTION_PASSWORD, '');
        } else {
            sync = function (success) {
                sso.signInComplete.disconnect(sync);

                if (success) {
                    synchronizeFavorites(callback, progressCallback);
                } else {
                    callback(false);
                }
            };

            sso.signInComplete.connect(sync);
            sso.checkLogin();
            return;
        }

        pro = function (progress, status) {
            _log('syncing progress ['+progress+'] status ['+status+']');
            if (progressCallback) {
                progressCallback(progress, status);
            }
            sync_status = status;
        }

        sync = function () {
            service.progressChanged.disconnect(pro);
            service.syncDone.disconnect(sync);
            if (sync_status === 1) {
                share.collected = false;
                collectObjects(callback);
            }
            else {
                callback(false);
            }
        }

        service.syncDone.connect(sync);
        service.progressChanged.connect(pro);
        service.start(service.TASK_SYNC);
    }
}

function cancelSynchronization() {
    if(!share) return;

    var service = share.syncService;
    if (service) {
        service.cancel();
    }
}

function getSortedKeys() {
    var keys = Object.keys(JS.objects);

    var sortedKeys = new Array();

    for (var i in keys){
        sortedKeys.push(keys[i]);
    }

    sortedKeys.sort(function(a,b) {
        var favA = JS.objects[a];
        var favB = JS.objects[b];

        return (favA.modificationDate < favB.modificationDate) ? 1 : -1;
    });

    return sortedKeys;
}
