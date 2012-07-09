.pragma library
//guidelines used:
// - naming item[.type][.subitem*].property[.state*]
// - casing:
//  * camelCase properties
//  * PascalCase component names
//  * CAPITAL constants
// - if only a single child available, combine parent and child
// - orders:
//  * width, height,
//  * top, left, bottom, right,
//  * landscape, portrait
//  * active, normal, disabled, down

//findings:
//I ) Qt.rgba, need not to be inside "", and evaluated with eval again, TODO 3

//TODO:
//I )Best way to get rid of Font enumerations?
//II ) Move property bindings into components themselves
//--DONE-- III ) Remove evals from where related to Qt.rgba
//IV ) Search for ?

//note: device contains the following nokia fonts, taken from Qt.fontFamilies() print
//-Nokia Pure,
//-Nokia Pure Headline,
//-Nokia Pure Text,
//-Nokia Sans,
//-Nokia Sans Cn,
//-Nokia Sans Maps,
//-Nokia Sans SemiBold,
//-Nokia Smiley,
//-Nokia Pure

//Nokialized ubuntu contains, taken from Qt.fontFamilies() print
//-Nokia Large,
//-Nokia Large Multiscript,
//-Nokia Sans Wide,
//-Nokia Sans Wide Multiscript,
//-Nokia Pure Multiscript

//familys
var NOKIA_SANS_WIDE = "Nokia Pure Text";
var NOKIA_STANDARD_LIGHT = "Nokia Pure Text Light";
var NOKIA_STANDARD_REGULAR = "Nokia Pure Text";
var NOKIA_STANDARD_BOLD = "Nokia Pure Text Bold";

var defaultFamily = NOKIA_SANS_WIDE;                                                                //Components.Common.font.family

// Nokia Service Terms and Privacy link:
var URL_TERMS = "http://nokia.mobi/privacy/services/terms/nokia-service";
var URL_POLICY = "http://nokia.mobi/privacy/policy";
var URL_YOUR_PRIVACY = "http://nokia.mobi/privacy/services/map-apps";

//sizes
var FONT_BIG = 36;
var FONT_NORMAL = 26;

//colors
var BLACK = "#000";
var WHITE = "#fff";
var SUBTITLE_GRAY = "#d4d4d4";
var BUTTON_DOWN_GRAY = "#464646";
var INPUT_COLOR = "#191919";
var INPUT_WATERMARK_COLOR = "#808080";

//paddings
var LEFT_PADDING_LANDSCAPE = 20;
var RIGHT_PADDING_LANDSCAPE = 20;
var LEFT_PADDING_PORTRAIT = 16;
var RIGHT_PADDING_PORTRAIT = 16;
                                                                                                    //COMPONENTS REFERENCE
var RegularText = {
    size: 24,
    family: NOKIA_STANDARD_REGULAR,
    color: WHITE
};

var LightText = {
    size: RegularText.size,
    family: NOKIA_STANDARD_LIGHT,
    color: RegularText.color
};

var ListItem = {
    height: 130,                                                                                    //Components.ListItem.height,
    backgroundSource: "../resources/listbg_plain.png",
    rightMargin: 60,
    leftMargin: 12,

    titleColor: {
        normal: WHITE,
        down: "#1080dd"
    },
    titleFamily: NOKIA_STANDARD_REGULAR,                                                            //Components.ListItem.line1.font.family,
    titleSize: FONT_BIG,                                                                            //Components.ListItem.line1.font.size,

    subtitleColor: {
        normal: SUBTITLE_GRAY,
        down: "#1080dd"
    },
    subtitleFamily: NOKIA_STANDARD_REGULAR,                                                         //Components.ListItem.line2.font.family,
    subtitleSize: FONT_NORMAL,                                                                      //Components.ListItem.line2.font.size,

    iconSource: "../resources/listItemIcon.png",
    iconLeftMargin: 16,

    arrowSource: "../resources/ButtonItemArrow.png",
    arrowLeftMargin: 16
};


var Button = {
    //TODO: I
    capitalization: "Font.AllUppercase",                                                            //Components.Button.font.capitalization,
    color: WHITE,                                                                                   //Components.Button.font.color,
    family: defaultFamily,
    size: 28,                                                                                       //Components.Button.font.size,
    //TODO: I
    weight: "Font.Bold",                                                                            //Components.Button.font.weight,

    backgroundColorPressed: BUTTON_DOWN_GRAY,
    backgroundImageSource: {
        hover: "../resources/driveButtonHover.png",                                                 //Components.imagePath + Components.Button.hover.borderImage.uri,
        disabled: "../resources/driveButtonDisabled.png",                                           //Components.imagePath + Components.Button.disabled.borderImage.uri,
        down: "../resources/driveButtonDown.png",                                                   //Components.imagePath + Components.Button.down.borderImage.uri,
        normal: "../resources/driveButtonNormal.png"                                                //Components.imagePath + Components.Button.down.borderImage.uri
    },
    backgroundImageWidth: 22,                                                                       //Components.Button.borderImage.width,
    backgroundImageHeight: 22,                                                                      //Components.Button.borderImage.height,

    horzontalPadding: 15,                                                                           //Components.Button.padding.horizontal,
    verticalPadding: 16,                                                                            //Components.Button.padding.vertical,
    height: 60,                                                                                     //Components.Button.height,
    spacing: 10,                                                                                    //Components.Button.spacing,

    iconWidth: 50,                                                                                  //Components.Button.icon.width,
    iconHeight: 50,                                                                                 //Components.Button.icon.height,
    iconSource: "../resources/driveButtonIcons.png",                                                //Components.imagePath + Components.Button.icon.uri,
    iconX: 0,                                                                                       //Components.Button.icon.x,
    iconY: 0,                                                                                       //Components.Button.icon.y,
    plain: {
        iconX: -50,                                                                                 //Components.Button.plain.icon.x,
        iconY: 0,                                                                                   //Components.Button.plain.icon.y,
    },
    home: {
        iconX: 0,                                                                                   //Components.Button.home.icon.x,
        iconY: -50                                                                                  //Components.Button.home.icon.y,
    },
    destination: {
        iconX: 0,                                                                                   //Components.Button.destination.icon.x,
        iconY: 0                                                                                    //Components.Button.destination.icon.y,
    }
};

var ActionBar = {
    width: 97,                                                                                      //Components.ActionBar.landscape.width
    backgroundImageSource:{
        landscape: "../resources/actionBarVertical.png",                                            //Components.ActionBar.landscape.backgroundImage.uri
        portrait: "../resources/actionBarHorizontal.png"                                            //Components.ActionBar.portrait.backgroundImage.uri,
    }
};

var ActionBarButton = {
    color: {
        normal: Qt.rgba(0, 0, 0, 0),                                                                //Components.ActionBarButton.normal.color,
        disabled: Qt.rgba(0, 0, 0, 0),                                                              //Components.ActionBarButton.disabled.color
        down: Qt.rgba(1, 1, 1, 0.15)                                                                //Components.ActionBarButton.down.color,
    },
    borderShadowSource: {
        landscape: "../resources/actionBarBorderTop.png",                                           //Components.ActionBarButton.border.landscape.shadow.uri
        portrait: "../resources/actionBarBorderLeft.png"                                            //Components.ActionBarButton.border.portrait.shadow.uri,
    },
    borderHeighlightSource: {
        landscape: "../resources/actionBarBorderBottom.png",                                        //Components.ActionBarButton.border.landscape.highlight.uri
        portrait: "../resources/actionBarBorderRight.png"                                           //Components.ActionBarButton.border.portrait.highlight.uri,
    }
};

var AddressItem = {
    height: ListItem.height,

    backgroundSource: ListItem.backgroundSource,
    defaultItemSource: "../resources/categories/mobile_list_address.png",                           //Components.defaultCategoryListIconUrl
    backgroundColorPressed: Button.backgroundColorPressed,

    headerColor: ListItem.titleColor.normal,
    headerFamily: defaultFamily,
    headerSize: 36,

    addressColor: ListItem.subtitleColor.normal,
    addressFamily: defaultFamily,
    addressSize: 26,

    distanceTextColor: "#57aaef",
    distanceTextFamily: defaultFamily,
    distanceTextSize: 26
};

var AssistanceItem = {
    backgroundSource: {
        landscape: "../resources/assistanceLandscapeBG.png",                                        //Components.imagePath + Components.AssistanceItem.landscape.background.uri
        portrait: "../resources/assistancePortraitBG.png"                                           //Components.imagePath + Components.AssistanceItem.portrait.background.uri,
    },
    backgroundWidthPortrait: 480,                                                                   //Components.AssistanceItem.portrait.background.width
    backgroundHeight: {
        landscape: 179,                                                                             //Components.AssistanceItem.landscape.background.height,
        portrait: 130                                                                               //Components.AssistanceItem.portrait.background.height
    },
    borderWidth: 1,
    borderColor: "#474747"
};

var ButtonItem = {
    backgroundSource: ListItem.backgroundSource,
    height: ListItem.height,                                                                        //Components.ButtonItem.height,
    iconSource: ListItem.iconSource,                                                                //Components.imagePath + "listItemIcon.png",

    titleFamily: ListItem.titleFamily,                                                              //Components.ButtonItem.line1.font.family,
    titleSize: ListItem.titleSize,                                                                  //Components.ButtonItem.line1.font.size,
    titleColor: {
        active: ListItem.titleColor.normal,                                                         //Components.ButtonItem.line1.font.colorActive,
        disabled: "#BBBBBB"                                                                         //Components.ButtonItem.line1.font.colorDisabled
    },

    subtitleFamily: ListItem.subtitleFamily,                                                        //Components.ButtonItem.line1.font.family,
    subtitleSize: ListItem.subtitleSize,                                                            //Components.ButtonItem.line2.font.size,
    subtitleColor: {
        active: ListItem.subtitleColor.normal,                                                      //Components.ButtonItem.line2.font.colorActive,
        disabled: "#BBBBBB"                                                                         //Components.ButtonItem.line2.font.colorDisabled
    },

    arrowSource: "../resources/arrow_list_item.png",                                                //Components.ButtonItem.arrowImage.normal
    arrowRightMargin: ListItem.arrowLeftMargin,
};

var Checkbox = {
    height:60,                                                                                      //Components.nps.checkbox_height
    iconWidth: 60,                                                                                  //Components.nps.checkbox_width
    spacing: 16,                                                                                    //Components.nps.checkbox_label_leftmargin

    source: {
        checked: "../resources/checkboxes/cb_selected.png",                                         //Components.CheckBox.checked.icon.uri
        unchecked: "../resources/checkboxes/cb_normal.png",                                         //Components.CheckBox.unchecked.icon.uri
        pressed: "../resources/checkboxes/cb_pressed.png",                                          //Components.CheckBox.pressed.icon.uri
        disabledChecked: "../resources/checkboxes/cb_active_disabled.png",                          //Components.CheckBox.disabledChecked.icon.uri
        disabledUnchecked: "../resources/checkboxes/cb_normal.png"                                  //Components.CheckBox.disabledUnchecked.icon.uri
    }

};

var Dashboard = {
    backgroundColor: BLACK,                                                                         //Components.Assistance.color,
};

var Dialog = {
    backgroundColor: BLACK,                                                                         //Components.Dialog.background.color,
    imageBottomMargin: 30,
    fontFamily: defaultFamily,
    textButtomMargin: 30,
    textSideMargin: 2 * 40,
    color: WHITE,                                                                                   //Components.Dialog.text.color,
    size: FONT_BIG,                                                                                 //Components.Dialog.text.size,
};

//TODO: should this be renamed to Sprites or something alike
var FunctionButton = {
    colorPressed: Button.backgroundColorPressed,                                                    //Components.Button.down.color,
    width: 80,                                                                                      //Components.ActionBarButton.width,
    height: 80,                                                                                     //Components.ActionBarButton.height,
    iconSource: "../resources/actionBarIcons.png",                                                  //Components.imagePath + Components.ActionBarButton.icon.uri,
    empty: {
        iconX: {
            normal: -80,
            disabled: -80,                                                                          //Components.ActionBarButton.icon.empty.disabled.x,
            down: -80                                                                               //Components.ActionBarButton.icon.empty.down.x,
        },
        iconY: {
            normal: 0,                                                                              //Components.ActionBarButton.icon.empty.normal.y,
            disabled: 0,                                                                            //Components.ActionBarButton.icon.empty.disabled.x
            down: 0                                                                                 //Components.ActionBarButton.icon.empty.down.y,
        }
    },
    back: {
        iconX: {
            normal:  0,                                                                             //Components.ActionBarButton.icon.back.normal.x,
            disabled: -80                                                                           //Components.ActionBarButton.icon.back.disabled.x,
        },
        iconY: {
            normal:  0,                                                                             //Components.ActionBarButton.icon.back.normal.y,
            disabled: 0                                                                             //Components.ActionBarButton.icon.back.disabled.x
        }
    },
    menu: {
        iconX: {
            normal:  0,                                                                             //Components.ActionBarButton.icon.menu.normal.x,
            disabled: -80                                                                           //Components.ActionBarButton.icon.menu.disabled.x,
        },
        iconY: {
            normal: -80,                                                                            //Components.ActionBarButton.icon.menu.normal.y,
            disabled: -80                                                                           //Components.ActionBarButton.icon.menu.disabled.x
        }
    },
    scrollUp:{
        iconX: {
            normal:  0,                                                                             //Components.ActionBarButton.icon.scrollUp.normal.x,
            disabled: -80                                                                           //Components.ActionBarButton.icon.scrollUp.disabled.x,
        },
        iconY: {
            normal: -160,                                                                           //Components.ActionBarButton.icon.scrollUp.normal.y,
            disabled: -160                                                                          //Components.ActionBarButton.icon.scrollUp.disabled.x
        }
    },
    scrollDown: {
        iconX: {
            normal: 0,                                                                              //Components.ActionBarButton.icon.scrollDown.normal.x,
            disabled: -80                                                                           //Components.ActionBarButton.icon.scrollDown.disabled.x,
        },
        iconY: {
            normal: -240,                                                                           //Components.ActionBarButton.icon.scrollDown.normal.y,
            disabled: -240                                                                          //Components.ActionBarButton.icon.scrollDown.disabled.x
        }
    },
    mapOptions: {
        iconX: {
            normal: 0                                                                               //Components.ActionBarButton.icon.mapOptions.normal.x,
        },
        iconY: {
            normal: -320                                                                            //Components.ActionBarButton.icon.mapOptions.normal.y,
        }
    },
    home: {
        iconX: {
            normal: -80                                                                               //Components.ActionBarButton.icon.mapOptions.normal.x,
        },
        iconY: {
            normal: -320                                                                            //Components.ActionBarButton.icon.mapOptions.normal.y,
        }
    },
    scrollLeftDark: {
        iconX: {
            normal:  0,                                                                             //Components.ActionBarButton.icon.scrollLeftDark.normal.x,
            disabled: -80,                                                                          //Components.ActionBarButton.icon.scrollLeftDark.disabled.x,
            down: -160                                                                              //Components.ActionBarButton.icon.scrollLeftDark.down.x
        },
        iconY: {
            normal: -400,                                                                           //Components.ActionBarButton.icon.empty.normal.y,
            disabled: -400,                                                                         //Components.ActionBarButton.icon.empty.disabled.x
            down: -400                                                                              //Components.ActionBarButton.icon.empty.down.y
        }
    },
    scrollRightDark: {
        iconX: {
            normal:  0,                                                                             //Components.ActionBarButton.icon.scrollRightDark.normal.x,
            disabled: -80,                                                                          //Components.ActionBarButton.icon.scrollRightDark.disabled.x,
            down: -160                                                                              //Components.ActionBarButton.icon.scrollRightDark.down.x
        },
        iconY: {
            normal: -480,                                                                           //Components.ActionBarButton.icon.scrollRightDark.normal.y,
            disabled: -480,                                                                         //Components.ActionBarButton.icon.scrollRightDark.disabled.x,
            down: -480                                                                              //Components.ActionBarButton.icon.scrollRightDark.down.y
        }
    }
};

var GuidancePanel = {
    height: {
        landscape: 170,                                                                             //Components.Guidance.landscape.height,
        portrait: 110                                                                               //Components.Guidance.portrait.height
    },
    guidanceBaseColor: {
        hasGPS: "#114E86",                                                                          //Components.Guidance.background.color,
        noGPS: "#919191"                                                                            //Components.Guidance.bgNoGPS.color
    },
    guidanceBaseHeighLandscape: 60,                                                                 //Components.Guidance.landscape.base.height,
    
    maneuverBaseWidth: {
        landscape: 210,                                                                             //"Components.Assistance.landscape.width", //Components.Guidance.landscape.maneuver.width,
        portrait:  130                                                                              //"Components.Assistance.portrait.height" //Components.Guidance.portrait.maneuver.width
    },
    maneuverBaseColor: {
        hasGPS: "#114E86",                                                                          //Components.Guidance.background.color,
        noGPS: "#919191"                                                                            //Components.Guidance.bgNoGPS.color
    },

    maneuverIconContainerWidth: 96,                                                                 //Components.Guidance.landscape.maneuver.icon.width,
    maneuverIconContainerHeight: 96,                                                                //Components.Guidance.landscape.maneuver.icon.height,

    maneuverIconContainerY: {
        landscape: 20,                                                                              //Components.Guidance.landscape.maneuver.icon.y,
        portrait: 7                                                                                 //Components.Guidance.portrait.maneuver.icon.y
    },
    maneuverIconFolder: "../resources/maneuverArrows/",

    streetFamily: defaultFamily,
    streetColor: {
        hasGPS: "#F5F5F5",                                                                          //Components.Guidance.landscape.street.font.color,
        noGPS: "#d7d7d7"                                                                            //Components.Guidance.noGPS.street.font.color
    },
    streetSize:  {
        landscape: 40,                                                                              //Components.Guidance.landscape.street.font.size,
        portrait: 34                                                                                //Components.Guidance.portrait.street.font.size
    },
    streetTopMargin: {
        landscape: 5,
        portrait: 10
    },

    distanceValueFamily: defaultFamily,
    distanceValueColor: {
        hasGPS: "#F5F5F5",                                                                          //Components.Guidance.landscape.distance.value.font.color,
        noGPS: "#d0d0d0",                                                                           //Components.Guidance.noGPS.distance.value.font.color
    },
    distanceValueSize: {
        landscape: 40,                                                                              //Components.Guidance.landscape.distance.value.font.size,
        portrait: 54                                                                                //Components.Guidance.portrait.distance.value.font.size
    },

    distanceUnitFamily: defaultFamily,
    distanceUnitColor: {
        hasGPS: "#F5F5F5",                                                                          //Components.Guidance.landscape.distance.unit.font.color,
        noGPS: "#d0d0d0"                                                                            //Components.Guidance.noGPS.distance.unit.font.color
    },
    distanceUnitSize: {
        landscape: 24,                                                                              //Components.Guidance.landscape.distance.unit.font.size,
        portrait: 28                                                                                //Components.Guidance.portrait.distance.unit.font.size
    }
};

var InfoBanner = {
    value: {
        color: "#FFFFFF",
        font: {
            pixelSize: 36,
            family: NOKIA_SANS_WIDE
        }
    },
    unit: {
        font: {
            pixelSize: 26,
            family: NOKIA_STANDARD_LIGHT
        }
    }//,

//    color: "WHITE",

//    family: defaultFamily,
//    size: 32,
//    textblock: {
//        topMargin:   { landscape: 32, portrait: 42 },
//        rightMargin: { landscape: 10, portrait: 20 },
//        leftMargin:  { landscape:  5, portrait: 10 },
//        spacing: 4
//    }
};

var InfoDistance = {
    widthRatioPortrait: 0.32,
    heightRatioLandscape: 0.37,
    leftMarginLandscape: 15,                                                                        //Components.AssistanceItem.landscape.margin.left,
    rightMarginLandscape: 65,                                                                       //Components.AssistanceItem.landscape.margin.right,

    valueItemFamily: defaultFamily,
    valueItemColor: "#F5F5F5",                                                                      //Components.AssistanceItem.landscape.value.font.color,
    valueItemSize: {
        landscape: 50,                                                                              //Components.AssistanceItem.landscape.value.font.size,
        portrait: 52                                                                                //Components.AssistanceItem.portrait.value.font.size
    },

    unitItemFamily: defaultFamily,
    unitItemColor:  "#9C9C9C",                                                                      //Components.AssistanceItem.portrait.unit.font.color
    unitItemSize: 24                                                                                //Components.AssistanceItem.portrait.unit.font.size
};

var InfoSpeed = {
    gradient: {
        from: "#A20310",
        to: "#710811"
    },
    widthRatio: {
        landscape: 0,
        portrait: 0.45                                                                              //Components.Assistance.portrait.info.speed.widthRatio
    },
    heightRatioLandscape: 0.37,                                                                     //Components.Assistance.landscape.info.speed.heightRatio,


    valueItemFamily: defaultFamily,
    valueItemColor: "#F5F5F5",                                                                      //Components.AssistanceItem.portrait.value.font.color,
    valueItemSize: 52,                                                                              //Components.AssistanceItem.portrait.value.font.size,

    unitItemFamily: defaultFamily,
    unitItemColor: "#9C9C9C",                                                                       //Components.AssistanceItem.portrait.unit.font.color,
    unitItemSize: 24,                                                                               //Components.AssistanceItem.portrait.unit.font.size,

    speedWarnerWidth: 88,
    speedWarnerHeight: 88,
    speedWarnerLeftMargin: 5,
    speedWarnerSource: "../resources/speedwarner.png",
    speedWarnerFamily: NOKIA_STANDARD_BOLD,
    speedWarnerColor: BLACK,
    speedWarnerSize: 32

};

var ListBrowser = {
    navigationBarHeight: 70,                                                                        //Components.ListBrowser.navigationBar.height,
    navigationBarColor: Qt.rgba(255, 255, 255, 0.7)                                                 //Components.ListBrowser.navigationBar.color
};

var Location = {
    height: 50,                                                                                     //Components.Location.landscape.height,
    backgroundOpacity: {
        hasGPS:  0.7,                                                                               //Components.Location.background.opacity,
        noGPS: 0.8,                                                                                 //Components.Location.noGPS.opacity
    },
    backgroundColor: {
        hasGPS:  WHITE,                                                                             //Components.Location.backgroundcolor,
        noGPS: "#9b0311"                                                                            //Components.Location.noGPS.color
    },
    color: {
        hasGPS: "#333333",                                                                          //Components.Location.landscape.font.color,
        noGPS: WHITE                                                                                //Components.Location.noGPS.font.color
    },
    family: defaultFamily,
    size: 32,                                                                                       //Components.Location.landscape.font.size,

    borderWidth: 2,                                                                                 //Components.Location.border.width,
    borderColor: "#c4c4c4",                                                                         //Components.Location.border.color,

    noGPSIconSource: "../resources/nogps.gif",                                                      //Components.imagePath + Components.Location.noGPS.icon.uri,
    noGPSIconWidth: 40,                                                                             //Components.Location.noGPS.icon.width,
    noGPSIconHeight: 40                                                                             //Components.Location.noGPS.icon.height
};

var ManeuverListItem = {
    topMargin: 20,                                                                                  //Components.ManeuverListItem.margins.top,
    leftMargin: 20,                                                                                 //Components.ManeuverListItem.margins.left,
    bottomMargin: 20,                                                                               //Components.ManeuverListItem.margins.bottom,
    rightMargin: 20,                                                                                //Components.ManeuverListItem.margins.right,
    backgroundColor:"#1282de",                                                                      //Components.ManeuverListItem.color,
    radius: 20,                                                                                     //Components.ManeuverListItem.radius,
    borderWidth: 2,                                                                                 //Components.ManeuverListItem.border.width,
    borderColor: WHITE,                                                                             //Components.ManeuverListItem.border.color,

    family: defaultFamily,
    color: ListItem.titleColor.normal,                                                              //Components.ManeuverListItem.details.h1.color,

    iconTopMargin: {
        landscape: 30,                                                                              //Components.ManeuverListItem.icon.landscape.margins.top,
        portrait: 0,                                                                                //Components.ManeuverListItem.icon.portrait.margins.top
    },
    iconBottomMargin: {
        landscape: 0,                                                                               //Components.ManeuverListItem.icon.landscape.margins.bottom,
        portrait: 10,                                                                               //Components.ManeuverListItem.icon.portrait.margins.bottom
    },
    iconWidth: {
        landscape: 96,                                                                              //Components.ManeuverListItem.icon.landscape.width,
        portrait: 50                                                                                //Components.ManeuverListItem.icon.portrait.width
    },
    iconHeight: {
        landscape: 96,                                                                              //Components.ManeuverListItem.icon.landscape.height,
        portrait: 50                                                                                //Components.ManeuverListItem.icon.portrait.height
    },

    iconSource:  {
        landscape: "../resources/maneuverArrows96x96.png",                                          //Components.imagePath + Components.ManeuverListItem.icon.landscape.uri,
        portrait: "../resources/maneuverArrows50x50Dark.png"                                        //Components.imagePath + Components.ManeuverListItem.icon.landscape.uri
    },
    iconSourceWidth: {
        landscape: 864,                                                                             //Components.ManeuverListItem.icon.landscape.source.size.width,
        portrait: 450                                                                               //Components.ManeuverListItem.icon.portrait.source.size.width
    },
    iconSourceHeight: {
        landscape: 576,                                                                             //Components.ManeuverListItem.icon.landscape.source.size.height,
        portrait: 300                                                                               //Components.ManeuverListItem.icon.portrait.source.size.height
    },
    columns: 9,                                                                                     //Components.ManeuverListItem.icon.landscape.source.columns,

    detailsLeftMargin: {
        landscape: 20,                                                                              //Components.ManeuverListItem.details.landscape.margin.left,
        portrait: 20                                                                                //Components.ManeuverListItem.details.portrait.margin.left
    },
    detailsRightMargin: {
        landscape: 20,                                                                              //Components.ManeuverListItem.details.landscape.margin.right,
        portrait: 20                                                                                //Components.ManeuverListItem.details.portrait.margin.right
    },
    detailsBottomMargin: {
        landscape: 20,                                                                              //Components.ManeuverListItem.details.landscape.margin.bottom,
        portrait: 2                                                                                 //Components.ManeuverListItem.details.portrait.margin.bottom
    },
    detailsSpacing: -4,                                                                             //Components.ManeuverListItem.details.spacing,

    titleSize: {
        landscape: 48,                                                                              //Components.ManeuverListItem.details.landscape.h1.size,
        portrait: 32,                                                                               //Components.ManeuverListItem.details.portait.h1.size
    },
    titleWeight: "Font.Bold",                                                                       //Components.ManeuverListItem.details.h1.weight,
    titleCapitaliation: "Font.Capitalize",                                                          //Components.ManeuverListItem.details.h1.capitalization,

    infoSize: {
        landscape: 40,                                                                              //Components.ManeuverListItem.details.landscape.h3.size,
        portrait: 28                                                                                //Components.ManeuverListItem.details.portait.h3.size
    },
    infoWeight: "Font.Normal",                                                                      //Components.ManeuverListItem.details.h3.weight,
    infoCapitaliation: "Font.MixedCase"                                                             //Components.ManeuverListItem.details.h3.capitalization
};

var MapControl = {
    margins: {top: 10, right: 10, bottom: 10, left: 10},
    width: 66,
    height: 66,
    compass: {
        background: "../resources/mapControls/compass_bg.png",
        needle: "../resources/mapControls/compass_needle.png"
    },
    button: {
        bg_normal: "../resources/mapControls/mapicon_bg.png",
        bg_pressed: "../resources/mapControls/mapicon_bg_pressed.png",

        zoomIn: {
            source: "../resources/mapControls/zoom_in_icon.png"
        },
        zoomOut: {
            source: "../resources/mapControls/zoom_out_icon.png"
        },
        settings: {
            source: "../resources/mapControls/setting_map_icon.png"
        },
        quickZoom: {
            source: "../resources/mapControls/quickzoom_icon.png"
        }
    }

};

var MapModeSwitch = {
    height: ListItem.height,
    leftMargin: 20,
    rightMargin: 20
};

var MapPerspectiveSwitch = {
    height: ListItem.height
};

var MiniMap = {
    coverColor: {
        day: "#fbfaf6",                                                                             //Components.Minimap.dayCoverColor,
        night: "#414141",                                                                           //Components.Minimap.nightCoverColor,
        satelite: "#3d4820",                                                                        //Components.Minimap.sateliteCoverColor
    },
    destinationIconSource: "../resources/preview_destination.png",                                  //Components.Minimap.destination.icon.uri,
    routeColor: {
        day: "#5784BB",                                                                             //Components.Route.dayColor,
        night: "#679DDA"                                                                            //Components.Route.nightColor
    },
    longTapArea: {
        width: 15,
        height: 15
    },
    longTapZoomThreshold: {
        min: 932000
    },

    dragMargin: 70
};

var PickMarker = {
    width: 50,
    height: 70,
    anchor: {
        x: 25,
        y: 60
    },
    marker: {
        source: "../resources/pick_from_map/svg/pick_icon_without_shadow.svg"
    },
    bigShadow: {
        source: "../resources/pick_from_map/svg/pick_icon_big_shadow.svg"
    },
    smallShadow: {
        source: "../resources/pick_from_map/svg/pick_icon_small_shadow.svg"
    },
    png: {
        withSmallShadow: "../resources/pick_from_map/png/pick_icon_with_small_shadow.png"
    }
};

var Page = {
    backgroundColor: BLACK,                                                                         //Components.Page.color,
    titleHeight: 56,                                                                                //Components.Page.title.height,
    titleLeftMargin: 16,
    titleColor: WHITE,                                                                              //Components.Page.font.color,
    titleFamily: NOKIA_STANDARD_LIGHT,                                                              //Components.Page.font.family,
    titleSize: 32                                                                                   //Components.Page.font.size
};

//var POIListItem = {
//    family: defaultFamily,

//    iconTopMargin: {
//        landscape: 35,                                                                              //Components.ResultListItem.icon.landscape.margins.top,
//        portrait: 45                                                                                //Components.ResultListItem.icon.portrait.margins.top
//    },
//    iconLeftMargin: {
//        landscape: 15,                                                                              //Components.ResultListItem.icon.landscape.margins.left,
//        portrait: 40                                                                                //Components.ResultListItem.icon.portrait.margins.left
//    },
//    iconWidth: 56,                                                                                  //Components.ResultListItem.icon.landscape.width,
//    iconHeight: 65,                                                                                 //Components.ResultListItem.icon.landscape.height,

//    iconSource: undefined,                                                                          //???Components.imagePath + Components.ResultListItem.icon.landscape.uri,
//    iconSourceWidth: 392,                                                                           //Components.ResultListItem.icon.landscape.source.size.width,
//    iconSourceHeight: 195,                                                                          //Components.ResultListItem.icon.landscape.source.size.height,

//    columns: 7,                                                                                     //Components.ResultListItem.icon.landscape.source.columns,

//    detailsTopMargin: {
//        landscape: 32,                                                                              //Components.ResultListItem.details.landscape.margin.top,
//        portrait: 42                                                                                //Components.ResultListItem.details.portrait.margin.top
//    },
//    detailsLeftMargin: {
//        landscape: 5,                                                                               //Components.ResultListItem.details.landscape.margin.left,
//        portrait: 10                                                                                //Components.ResultListItem.details.portrait.margin.left
//    },
//    detailsRightMargin: {
//        landscape: 10,                                                                              //Components.ResultListItem.details.landscape.margin.right,
//        portrait: 20                                                                                //Components.ResultListItem.details.portrait.margin.right
//    },
//    detailsSpacing: -4,                                                                             //Components.ResultListItem.details.spacing,

//    titleSize: ListItem.titleSize,                                                                  //Components.ResultListItem.details.landscape.h1.size,
//    //TODO: I
//    titleWeight: "Font.Normal",                                                                     //Components.ResultListItem.details.h1.weight,
//    titleCapitaliation: "Font.Capitalize",                                                          //Components.ResultListItem.details.h1.capitalization,
//    titleColor: ListItem.titleColor.normal,                                                         //Components.ResultListItem.details.h1.color,

//    addressSize: ListItem.subtitleSize,                                                             //Components.ResultListItem.details.landscape.h3.size,
//    addressWeight: "Font.Normal",                                                                   //Components.ResultListItem.details.h3.weight,
//    addressCapitaliation: "Font.MixedCase",                                                         //Components.ResultListItem.details.h3.capitalization,
//    addressColor: ListItem.subtitleColor.normal,                                                    //Components.ResultListItem.details.h3.color,

//    distanceSize: 42,                                                                               //Components.ResultListItem.distance.size,
//    //TODO: I
//    distanceWeight: "Font.Normal",                                                                  //Components.ResultListItem.distance.weight,
//    distanceCapitaliation: "Font.MixedCase",                                                        //Components.ResultListItem.distance.capitalization,
//    distanceColor: "#282828"                                                                        //Components.ResultListItem.distance.color,
//};

var RecentSearchListItem = {
    backgroundSource: {
        normal: ListItem.backgroundSource, //undefined,                                                                          //???Components.RecentSearchListItem.background.normal,
        plain: ListItem.backgroundSource                                                            //"../resources/" + Components.RecentSearchListItem.background.plain
    },
    backgroundColorPressed: Button.backgroundColorPressed,                                          //Components.RecentSearchListItem.background.pressed,
    marginSides: 2 * 20,
    topMargin: 15,
    leftMargin: 12,
    family: defaultFamily,
    size: 38,                                                                                       //Components.RecentSearchListItem.text.size,
    color: ListItem.titleColor.normal                                                               //Components.RecentSearchListItem.text.color

};

var ScrollBar = {
    width: 87                                                                                       //Components.ScrollBar.width
};

var ScrollBarButton = {
    backgroundSource: "../resources/scrollButtonLandscape.png",                                     //Components.imagePath + Components.ScrollBar.Button.uri,
    foregroundColor: {
        normal: ActionBarButton.color.normal,                                                       //Components.ActionBarButton.normal.color,
        disabled: ActionBarButton.color.disabled,                                                   //Components.ActionBarButton.disabled.color,
        down: ActionBarButton.color.down                                                            //Components.ActionBarButton.down.color
    }
};

var ScrollPositionIndicator = {
    backgroundColor: WHITE,                                                                         //Components.ScrollPositionIndicator.background.color,
    backgroundOpacity: 0,                                                                           //Components.ScrollPositionIndicator.background.opacity,

    indicatorColor: "#999",                                                                         //Components.ScrollPositionIndicator.indicator.color,
    indicatorOpacity: 0.8,                                                                          //Components.ScrollPositionIndicator.indicator.opacity
};

var InputBackground = {
    backgroundSource: {
        active: "../resources/searchBoxBorderActive.png",                                           //Components.SearchBox.background.active
        normal: "../resources/searchBoxBorderNormal.png",                                           //Components.SearchBox.background.normal,
        disabled: "../resources/searchBoxBorderDisabled.png"                                        //Components.SearchBox.background.disabled
    }
};

var SearchBox = {
    height: 100,
    backgroundColor: "#EFF0F1",
    backgroundSource: InputBackground.backgroundSource,
    margins: 20,

    iconSource: "../resources/searchBoxIcon.png",                                                   //Components.SearchBox.icon.uri,
    iconTopMargin: 34,
    iconLeftMargin: 35,

//    watermarkTopMargin: 28,
//    watermarkLeftMargin: 80,
//    watermarkRightMargin: 18,
//    watermarkColor: INPUT_WATERMARK_COLOR,
//    watermarkSize: FONT_BIG,
//    watermarkFamily: defaultFamily,

    inputTopMargin: 28,
    inputLeftMargin: 76,
    inputRightMargin: 18,
    inputSize: FONT_BIG,
    inputFamily: defaultFamily,

    clearIconSource: "../resources/searchBoxClearIcon.png",                                         //Components.SearchBox.clearIcon.uri,
    clearIconMargins: 30,

    spinnerSource: "../resources/spinner_inputfield.gif",                                           //Components.imagePath + Components.SmallSpinner.uri,
    spinnerMargins: 30

};

var SearchResultListItem = {
    icon: {
        topMargin:  { landscape: 35, portrait: 45 },
        leftMargin: { landscape: 15, portrait: 40 }
    },
    distanceLabel: {
        fontsize: 42,
        color: "#282828"
    }
};

var AddressTextBlock = {
    icon: {
        topMargin:  { landscape: 35, portrait: 45 },
        leftMargin: { landscape: 15, portrait: 40 }
    },
    textblock: {
        topMargin:   { landscape: 32, portrait: 42 },
        rightMargin: { landscape: 10, portrait: 20 },
        leftMargin:  { landscape:  5, portrait: 10 },
        spacing: 4
    }
};

var Slider = {
    backgroundSource: "../resources/voicedownloads/progress_bar_bg.png",
    foregroundSource: "../resources/voicedownloads/progress_bar.png",

    backgroundTouchAreaHeight: 100,

    valueBackgroundSource: "../resources/slidervalue.png",                                          //Components.nps.progress_value_source,
    valueColor: "#282828",                                                                          //Components.nps.progress_value_color,
    valueFamily: NOKIA_STANDARD_LIGHT,                                                              //Components.nps.progress_value_family,
    valueSize: 22,                                                                                  //Components.nps.progress_value_size,

    arrowSource: "../resources/slidervaluearrowdown.png",                                           //Components.nps.progress_value_arrow_source,
    arrowBottomMargin: 5,                                                                           //Components.nps.progress_value_arrow_bottommargin,

    handleSource: {
        normal: "../resources/sliderhandle.png",                                                    //Components.nps.progress_nobe_source,
        down: "../resources/sliderhandlepressed.png",                                               //Components.nps.progress_nobe_source_down
    },
    handleWidth: 42,                                                                                //Components.nps.progress_nobe_width,
    handleTouchAreaWidth: 100,                                                                      //Components.nps.progress_nobe_toucharea_width,
    handleTouchAreaHeight: 100,                                                                     //Components.nps.progress_nobe_toucharea_height,

    minimumValueTextSize: 24,                                                                       //Components.nps.theone_size,
    minimumValueTextColor: WHITE,                                                                   //Components.nps.theone_color,
    minimumValueTextFamily: NOKIA_STANDARD_REGULAR,                                                 //Components.nps.theone_family,

    maximumValueTextSize: 24,                                                                       //Components.nps.theten_size,
    maximumValueTextColor: WHITE,                                                                   //Components.nps.theten_color,
    maximumValueTextFamily: NOKIA_STANDARD_REGULAR                                                  //Components.nps.theten_family

};

var SpeedWarnerSwitch = {
    height: ListItem.height
};

var SpeedWarnerSettingsPage = {
    columnAnchors: {
        leftMargin: 16,
        rightMargin: 16
    },
    textFontFamily: NOKIA_SANS_WIDE,
    textColor1: "#fff",
    textColor2: "#d4d4d4",
    textFontSize1: 32,
    textFontSize2: 26,

    sliderHeight: 160,
    sliderValueFontSize: 36,
    sliderUnitFontSize: 24
};

var Spinner = {
    width: 98,                                                                                      //Components.Spinner.width,
    height: 98,                                                                                     //Components.Spinner.height,
    source: "../resources/spinnerOnBlack.gif"                                                       //Components.imagePath + Components.Spinner.uri
};

var SuggestionListItem = {
    backgroundColor: "#EFF0F1",
    backgroundSource: "../resources/listbg_plain_light_border.png",
    rightMargin: 20,
    leftMargin: 12,
    size:  RecentSearchListItem.size,                                                               //Components.RecentSearchListItem.text.size,
    color:  BLACK,
    family: defaultFamily
};

var ToggleButton = {
    backgroundSource: {
        normal: "../resources/toggleButtonNormalEntire.png",                                        //Components.imagePath + Components.ToggleButton.normal.borderImage.uri,
        disabled: "../resources/toggleButtonNormalEntire.png",                                      //Components.imagePath + Components.ToggleButton.disabled.borderImage.uri,
        down: "../resources/toggleButtonSelectedEntire.png",                                        //Components.imagePath + Components.ToggleButton.down.borderImage.uri,
        hover: "../resources/toggleButtonNormalEntire.png"                                          //Components.imagePath + Components.ToggleButton.hover.borderImage.uri,
    },
    backgroundWidth: 30,                                                                            //Components.ToggleButton.borderImage.width,
    leftBorder: 30,                                                                                 //Components.ToggleButton.borderImage.width,
    rightBorder: 30,                                                                                //Components.ToggleButton.borderImage.width,
    topBorder: 40,                                                                                  //Components.ToggleButton.borderImage.height,
    bottomBorder: 40,                                                                               //Components.ToggleButton.borderImage.height,

    height: {
        landscape: 100,                                                                             //Components.ToggleButton.landscape.height,
        portrait: 88                                                                                //Components.ToggleButton.portrait.height
    },
    leftMargin:  {
        landscape: 10,                                                                              //Components.ToggleButton.landscape.margin.left,
        portrait: 10,                                                                               //Components.ToggleButton.portrait.height.left
    },
    rightMargin:  {
        landscape: 10,                                                                              //Components.ToggleButton.landscape.margin.right,
        portrait: 10,                                                                               //Components.ToggleButton.portrait.margin.right
    },

    color: WHITE,                                                                                   //Components.ToggleButton.font.color,
    family: defaultFamily,
    //TODO: I
    weight: "Font.Bold",                                                                            //Components.ToggleButton.font.weight,
    size: 30                                                                                        //Components.ToggleButton.font.size
};

var ToggleSwitch = {
    height: {
        landscape: ToggleButton.height.landscape,                                                   //Components.ToggleButton.landscape.height,
        portrait: ToggleButton.height.portrait                                                      //Components.ToggleButton.portrait.height
    },
    leftMargin: 16,
    rightMargin: 16,
    spacing: 2                                                                                      //Components.ToggleButton.spacing
};

//var ExtendedTextEdit = {
//    size: RegularText.size,
//    color: INPUT_COLOR,
//    family: RegularText.family,
//    defaultHeight: 88

//};

var ExtendedTextInput = {
    size: RegularText.size,
    family: RegularText.family,
    defaultHeight: 60,
    color: {
        text: INPUT_COLOR,
        watermark: INPUT_WATERMARK_COLOR
    }
};

var SettingsButton = {
    width: 68,
    height: 68,
    icon: {
        width: 68,
        height: 68,
        source: {
            normal: "../resources/settingsButtonNormal.png",
            down: "../resources/settingsButtonDown.png"
        }
    }
};

var LaneAssistanceBar = {
    height: 92,
    opacity: 0.7,

    maxLanesSupported: 8,

    background: {
        color: "#114E86"
    },

    item: {
        width: 57
    },

    separator: {
        width: 3
    },

    icon: {
        uri: "../resources/laneAssistanceArrows/",

        width: 50,
        height: 50,

        separator: {
            uri: "separator.png"
        },

        item: {
            dots: "../dots",
            ext: ".png"
        }
    }
};

var PickLocationPageBar = {
    height: {
        min: 50,
        max: 80
    }
};

var Favorites = {
    icon: {
        uri: "../resources/favorites/",
        uri2: "../../resources/favorites/",
        listItemDelete: "list-item-delete.png",
        listItemEdit: "list-item-edit.png",
        listItemSync: "list-item-synchronize.png",
        addToFavorites: "add-to-favourites.png",
        sync: {
            uri: "icon_sync.png"
        },
        cancel: {
            normal: "cancel.png",
            down: "cancel_down_state.png"
        }
    },
    button: {
        icon: {
            add: "button-add-to-favourites.png",
            addDown: "button-add-to-favourites-down.png",
            remove: "button-remove-from-favourites.png",
            removeDown: "button-remove-from-favourites-down.png",
        },
        width: 68,
        height: 68
    },
    notification: {
        backgroundColor: "#000000",
        opacity: 0.9,
        textSideMargin: 40,
        textSize: 36,
        locationColor: "#1080DD",
        actionColor: "#FFFFFF",
        locationFontFamilty: NOKIA_STANDARD_BOLD,
        actionFontFamilty: NOKIA_STANDARD_REGULAR,
        duration: 1500 // ms
    },
    dialog: {
        inputSize: FONT_BIG,
        inputFamily: defaultFamily,
        inputLeftMargin: 20,
           inputRightMargin: 20,
           inputTopMargin: 10
    }
};


//unused
//ActionButtonWithBase.qml
//var ListBrowser2;
//var ManeuverListItem
//var ManeuverListItem2;
//var POIBrowser;
//var POIListItem
//var ListItem
