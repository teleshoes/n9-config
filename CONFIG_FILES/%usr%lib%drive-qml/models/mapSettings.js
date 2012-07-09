var PoiCategories = [
        {id: Icon.Airport,                  categoryTitle: qsTrId("qtn_drive_poi_airports_item"),            turnOn: true},
        {id: Icon.AmusementPark,            categoryTitle: qsTrId("qtn_drive_poi_amusement_park_item"),      turnOn: false},
        {id: Icon.Carrepair,                categoryTitle: qsTrId("qtn_drive_poi_car_repair_item"),          turnOn: true},
        {id: Icon.CashDispenser,            categoryTitle: qsTrId("qtn_drive_poi_cash_dispenser_item"),      turnOn: false},
        {id: Icon.Cinema,                   categoryTitle: qsTrId("qtn_drive_poi_cinema_item"),              turnOn: false},
        {id: Icon.Education,                categoryTitle: qsTrId("qtn_drive_poi_education_item"),           turnOn: false},
        {id: Icon.ExhibitionCentre,         categoryTitle: qsTrId("qtn_drive_poi_exhibition_centre_item"),   turnOn: false},
        {id: Icon.GovernmentOffice,         categoryTitle: qsTrId("qtn_drive_poi_government_office_item"),   turnOn: false},
        {id: Icon.Hospital,                 categoryTitle: qsTrId("qtn_drive_poi_hospital_item"),            turnOn: false},
        {id: Icon.Hotel,                    categoryTitle: qsTrId("qtn_drive_poi_hotel_item"),               turnOn: false},
        {id: Icon.Library,                  categoryTitle: qsTrId("qtn_drive_poi_library_item"),             turnOn: false},
        {id: Icon.Museum,                   categoryTitle: qsTrId("qtn_drive_poi_museum_item"),              turnOn: false},
        {id: Icon.Shop,                     categoryTitle: qsTrId("qtn_drive_poi_shop_item"),                turnOn: false},
        {id: Icon.SportOutdoor,             categoryTitle: qsTrId("qtn_drive_poi_outdoor_sports_item"),      turnOn: false},
        {id: Icon.Parking,                  categoryTitle: qsTrId("qtn_drive_poi_parking_item"),             turnOn: true},
        {id: Icon.PetrolStation,            categoryTitle: qsTrId("qtn_drive_poi_petrol_station_item"),      turnOn: true},
        {id: Icon.Pharmacy,                 categoryTitle: qsTrId("qtn_drive_poi_pharmacy_item"),            turnOn: false},
        {id: Icon.PlaceOfWorship,           categoryTitle: qsTrId("qtn_drive_poi_religious_place_item"),     turnOn: false},
        {id: Icon.Police,                   categoryTitle: qsTrId("qtn_drive_poi_police_item"),              turnOn: false},
        {id: Icon.PostOffice,               categoryTitle: qsTrId("qtn_drive_poi_post_office_item"),         turnOn: false},
        {id: Icon.RentACarFacility,         categoryTitle: qsTrId("qtn_drive_poi_car_rental_item"),          turnOn: true},
        {id: Icon.RestArea,                 categoryTitle: qsTrId("qtn_drive_poi_rest_area_item"),           turnOn: true},
        {id: Icon.Restaurant,               categoryTitle: qsTrId("qtn_drive_poi_restaurant_item"),          turnOn: false},
        {id: Icon.Theatre,                  categoryTitle: qsTrId("qtn_drive_poi_theatre_item"),             turnOn: false},
        {id: Icon.TouristAttraction,        categoryTitle: qsTrId("qtn_drive_poi_tourist_attraction_item"),  turnOn: false},
        {id: Icon.TouristInformationCentre, categoryTitle: qsTrId("qtn_drive_poi_tourist_information_item"), turnOn: false}
];

var poiSorted = false, len = PoiCategories.length;

function getSortedPoiCategories() {
    if (!poiSorted) {
        PoiCategories.sort(comparePoi);
        poiSorted = true;
    }
    return PoiCategories;
}

function comparePoi(a, b) {
    var titleA = a.categoryTitle.toLowerCase(),
        titleB = b.categoryTitle.toLowerCase();

    return titleA < titleB ? -1 : (titleA > titleB ? 1 : 0);
}

function changePoiVisibility(itemId) {
    for (var i = 0; i < len; i++) {
        if (PoiCategories[i].id == itemId) {
            PoiCategories[i].turnOn = !PoiCategories[i].turnOn;
        }
    }
}

/*
    If deserialize is slow it can be speeded up by stroring *sorted* ids
 */
function serialize() {
    var selectedIds = [];

    for (var i=0; i<len; i++) {
        if (PoiCategories[i].turnOn) {
           selectedIds.push(PoiCategories[i].id);
        }
    }

    return selectedIds.join(",");
}

function deserialize(serializedIds) {
    if (serializedIds === undefined) return;
    var selectedIds = serializedIds.split(",");

    for (var i = 0; i < len; i++) {
        var poi = PoiCategories[i];
        poi.turnOn = in_array(poi.id, selectedIds);
    }
}

function in_array(needle, haystack) {
    for (var i=0, len = haystack.length; i<len; i++) {
        if (haystack[i] == needle) return true;
    }
    return false;
}
