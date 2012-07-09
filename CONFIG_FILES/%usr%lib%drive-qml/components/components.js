// components.js
.pragma library

// default paths
var resourcePath = "../resources/";
var componentsPath = "../components/";
var imagePath = resourcePath + "";

var defaultCategoryListIconUrl = resourcePath + "/categories/mobile_list_address.png";
var defaultCategoryListIconUrlFav = resourcePath + "/categories/mobile_list_address_fav.png";
var defaultCategoryMapIconUrl = resourcePath + "/categories/mobile_map_address.png";
var defaultCategoryMapIconUrlFav = resourcePath + "/categories/mobile_map_address_fav.png";

// common 'styles'
var Common = {
    font: {
        family: "Nokia Pure Text"
    }
};

// Page
var Page = {
    landscape: {
    },
    portrait: {
    },
    font: {
        family: "Nokia Pure Text Light",
        size: 32,
        color: "#FFFFFF"
    },
    title: {
        height: 56
    },
    color: "#000000"
};

// Map Controls
var MapControls = {
    margins: {top: 10, right: 10, bottom: 10, left: 10},
    width: 72,
    height: 72,
    base: {
        color: "#000000",
        opacity: 0.4,
        border: {
            width: 2,
            color: "#FFFFFF"
        },
        maximize: {
            radius: 14
        },
        zoomIn: {
            radius: 14
        },
        zoomOut: {
            radius: 14
        },
        compass: {
            radius: 34
        }
    },
    icon: {
        uri: "mapControls.png",
        width: 72,
        height: 72,
        maximize: {
            presetAngle: 0,
            normal: { x: 0, y: -288, origin: {x: 36, y: 36} },
            down: { x: -72, y: -288, origin: {x: 36, y: 36} },
            background: {x: -144, y: 0, origin: {x: 36, y: 36} }
        },
        zoomIn: {
            presetAngle: 0,
            normal: { x: 0, y: -72, origin: {x: 36, y: 36} },
            down: { x: -72, y: -72, origin: {x: 36, y: 36} },
            background: {x: -144, y: 0, origin: {x: 36, y: 36} }
        },
        zoomOut: {
            presetAngle: 0,
            normal: {x: 0, y: 0, origin: {x: 36, y: 36} },
            down: {x: -72, y: 0, origin: {x: 36, y: 36} },
            background: {x: -144, y: 0, origin: {x: 36, y: 36} }
        },
        compass: {
            presetAngle: -45,
            normal: { x: 0, y: -144, origin: {x: 37, y: 33} },
            down: { x: -72, y: -144, origin: {x: 37, y: 37} },
            background: { x: 0, y: -216, origin: {x: 37, y: 39} }
        }
    },
    background: {
        opacity: 0.7
    }
};

// Action Bar
var ActionBar = {
    button: {
        width: 80,
        height: 80,
        icon: {
            uri: "actionBarIcons.png"
        }
    },
    landscape: {
        width: 97,
        backgroundImage: {
            uri: "actionBarVertical.png"
        }
    },
    portrait: {
        width: 97,
        backgroundImage: {
            uri: "actionBarHorizontal.png"
        }
    }
};

// Action Bar Button
var ActionBarButton = {
    width: 80,
    height: 80,

    //states
    normal: {
        color: "Qt.rgba(0,0,0,0)"
    },
    down: {
        color: "Qt.rgba(255,255,255,0.15)"
    },
    disabled: {
        color: "Qt.rgba(0,0,0,0)"
    },

    border: {
        landscape: {
            shadow: {
                uri: "actionBarBorderTop.png"
            },
            highlight: {
                uri: "actionBarBorderBottom.png"
            }
        },
        portrait: {
            shadow: {
                uri: "actionBarBorderLeft.png"
            },
            highlight: {
                uri: "actionBarBorderRight.png"
            }
        }
    },
    icon: {
        uri: "actionBarIcons.png",
        empty: {
            normal: {x: -80, y: 0},
            down: {x: -80, y: 0},
            disabled: {x: -80, y: 0}
        },
        back: {
            normal: {x: 0, y: 0},
            disabled: {x: -80, y: 0}
        },
        menu: {
            normal: {x: 0, y:-80},
            disabled: {x: -80, y:-80}
        },
        scrollUp: {
            normal: {x: 0, y:-160},
            disabled: {x: -80, y:-160}
        },
        scrollDown: {
            normal: {x: 0, y:-240},
            disabled: {x: -80, y:-240}
        },
        mapOptions: {
            normal: {x: 0, y:-320}
        },
        //place holder
        speedLimitIcon: {
            normal: {x: -80, y:-320}
        },
        scrollLeftDark: {
            normal: {x: 0, y:-400},
            disabled: {x: -80, y:-400},
            down: {x: -160, y:-400}
        },
        scrollRightDark: {
            normal: {x: 0, y:-480},
            disabled: {x: -80, y:-480},
            down: {x: -160, y:-480}
        },
    }
};

// ActionBarButton with background
var ActionButtonWithBase = {
    width: 72,
    height: 72,
    radius: 14,
    base: {
        color: "#000000",
        opacity: 0.2,
        border: {
            width: 2,
            color: "#FFFFFF"
        }
    }
};

// Scroll bar
var ScrollBar = {
    width: 87,
    Button: {
        uri: "scrollButtonLandscape.png"
    }
};

// Drive Button
var Button = {
    height: 60,
    padding: {
        horizontal: 15,
        vertical: 15
    },
    spacing: 10,
    icon: {
        x: 0,
        y: 0,
        width: 50,
        height: 50,
        uri: "driveButtonIcons.png"
    },
    borderImage: {
        width: 22,
        height: 22
    },
    font: {
        size: 28,
        weight: "Font.Bold",
        style: "Text.Raised",
        capitalization: "Font.AllUppercase",
        color: "#FFFFFF"
    },

    // states
    normal: {
        borderImage: {
            uri: "driveButtonNormal.png"
        }
    },
    hover: {
        borderImage: {
            uri: "driveButtonHover.png"
        }
    },
    disabled: {
        borderImage: {
            uri: "driveButtonDisabled.png"
        }
    },
    down: {
        borderImage: {
            uri: "driveButtonDown.png"
        },
        color: "#464646"
    },

    // types
    plain: {
        icon: {x: -50, y: 0}
    },
    home: {
        icon: {x: 0, y: -50}
    },
    destination: {
        icon: {x: 0, y: 0}
    }
};

// Assistance
var Assistance = {
    color: "#000000",
    landscape: {
        width: 210,
        info: {
            speed: { heightRatio: 0.37 },
            distance: {heightRatio: 0.37 }
        }
    },
    portrait: {
        height: 130,
        info: {
            speed: { widthRatio: 0.45 },
            distance: { widthRatio: 0.32 }
        }
    }
};

// Assistance Item
var AssistanceItem = {
    common: {
        limit: {
            color: {
                normal: "Qt.rgba(0,0,0,0)",
                exceded: "Qt.rgba(183/255,10/255,25/255,0.9)"
            }
        }
    },
    landscape: {
        border: {
            width: "parent.width",
            height: 2,
            uri: "assistanceItemBorderLandscape.png"
        },
        background: {
            width: 210,
            height: 179,
            uri: "assistanceLandscapeBG.png"
        },
        margin: { left: 15, right: 65 },
        value: {
            font: {
                size: 50,
                color: "#F5F5F5"
            }
        },
        unit: {
            font: {
                size: 24,
                color: "#9C9C9C"
            }
        },
        limit: {
            margins: {bottom: 2},
            font: {
                size: 30,
                color: "#333333",
                weight: "Font.Bold",
                letterSpacing: -2,
                offset: { vertical: -2, horizontal: -1 }
            }
        }
    },
    portrait: {
        height: 130,
        border: {
            width: 2,
            height: "parent.height",
            uri: "assistanceItemBorderPortrait.png"
        },
        background: {
            width: 480,
            height: 130,
            uri: "assistancePortraitBG.png"
        },
        value: {
            font: {
                size: 52,
                color: "#F5F5F5"
            }
        },
        unit: {
            font: {
                size: 24,
                color: "#9C9C9C"
            }
        },
        limit: {
            margins: {left: 15, right: 2},
            font: {
                size: 30,
                color: "#333333",
                weight: "Font.Bold",
                letterSpacing: -2,
                offset: { vertical: -2, horizontal: -1 }
            }
        }
    }
};

// Guidance
var Guidance = {
    background: {
        color: "#114E86"
    },
    bgNoGPS: {
        color: "#919191",
    },
    noGPS: {
        street: {
            font: {
                color: "#d7d7d7"
            }
        },
        distance: {
            value: {
                font: {
                    color: "#d0d0d0"
                }
            },
            unit: {
                font: {
                    color: "#d0d0d0"
                }
            }
        }
    },
    landscape: {
        width: "0.8 * parent.width",
        height: 170,
        base: {
            height: 60
        },
        maneuver: {
            width: "Components.Assistance.landscape.width",
            height: "parent.height",
            icon: {
                width: 96,
                height: 96,
                y: 20,
                uri: "maneuverArrows96x96.png"
            }
        },
        street: {
            font: {
                size: 40,
                color: "#F5F5F5"
            }
        },
        distance: {
            value: {
                font: {
                    size: 40,
                    color: "#F5F5F5"
                }
            },
            unit: {
                font: {
                    size: 24,
                    color: "#F5F5F5"
                }
            }
        }
    },
    portrait: {
        width: "parent.width",
        height: 110,
        base: {
            height: "guidance.height"
        },
        maneuver: {
            width: "Components.Assistance.portrait.height",
            height: "parent.height",
            icon: {
                width: 96,
                height: 96,
                y: 7,
                uri: "maneuverArrows96x96.png"
            }
        },
        street: {
            font: {
                size: 34,
                color: "#F5F5F5"
            }
        },
        distance: {
            value: {
                font: {
                    size: 54,
                    color: "#F5F5F5"
                }
            },
            unit: {
                font: {
                    size: 28,
                    color: "#F5F5F5"
                }
            }
        }
    }
};

var Route = {
    nightColor:"#679DDA",
    dayColor: "#5784BB"
}

// Location
var Location = {
    border: {
        width: 2,
        color: "#c4c4c4"
    },
    background: {
        opacity: 0.7,
        color: "#FFFFFF"
    },
    landscape: {
        height: 50,
        font: {
            size: 32,
            color: "#333333"
        }
    },
    portrait: {
        height: 50,
        font: {
            size: 32,
            color: "#333333"
        }
    },
    noGPS: {
        //background
        color: "#9b0311",
        opacity: 0.8,
        font: {
            size: 32,
            color: "#FFF"
        },
        icon: {
            uri: "nogps.gif",
            width: 40,
            height: 40
        }
    }
};

// ToggleButton
var ToggleButton = {
    spacing: 2,
    landscape: {
        height: 100,
        margin: {top: 10, right: 10, bottom: 10, left: 10}
    },
    portrait: {
        height: 88,
        margin: {top: 10, right: 10, bottom: 10, left: 10}
    },
    borderImage: {
        width: 30,
        height: 40
    },
    font: {
        size: 30,
        weight: "Font.Bold",
        color: "#FFFFFF"
    },

    // states
    normal: {
        borderImage: {
            uri: "toggleButtonNormalEntire.png"
        }
    },
    hover: {
        borderImage: {
            uri: "toggleButtonNormalEntire.png"
        }
    },
    down: {
        borderImage: {
            uri: "toggleButtonSelectedEntire.png"
        }
    },
    disabled: {
        borderImage: {
            uri: "toggleButtonNormalEntire.png"
        }
    }
};

// ListBrowser
var ListBrowser = {
    navigationBar: {
        height: 70,
        color: "Qt.rgba(255,255,255,0.7)"
    }
};

// ListBrowser elements (components)
// ManeuverListItem
var ManeuverListItem = {
    margins: {top: 20, right: 20, bottom: 20, left: 20},
    color: "#1282de",
    radius: 20,
    border: {
        width: 2,
        color: "#FFFFFF"
    },
    icon: {
        landscape: {
            width: 96,
            height: 96,
            margins: {top: 30, right: 0, bottom: 0, left: 0},
            uri: "maneuverArrows96x96.png",
            source: {
                size: {width: 864, height: 576},
                columns: 9,
                rows: 6
            }
        },
        portrait: {
            width: 50,
            height: 50,
            margins: {top: 0, right: 0, bottom: 10, left: 0},
            uri: "maneuverArrows50x50Dark.png",
            source: {
                size: {width: 450, height: 300},
                columns: 9,
                rows: 6
            }
        }
    },
    details: {
        spacing: -4,

        h1: {
            weight: "Font.Bold",
            capitalization: "Font.Capitalize",
            color: "#FFFFFF"
        },
        h2: {
            weight: "Font.Normal",
            capitalization: "Font.MixedCase",
            color: "#FFFFFF"
        },
        h3: {
            weight: "Font.Normal",
            capitalization: "Font.MixedCase",
            color: "#FFFFFF"
        },

        landscape: {
            h1: { size: 48 },
            h2: { size: 40 },
            h3: { size: 32 },
            margin: {top: 80, right: 20, bottom: 20, left: 20}
        },
        portrait: {
            h1: { size: 32 },
            h2: { size: 28 },
            h3: { size: 24 },
            margin: {top: 7, right: 20, bottom: 2, left: 20}
        }
    }
};

// Search ResultListItem
var ResultListItem = {
    icon: {
        landscape: {
            width: 56,
            height: 65,
            margin: {top: 35, right: 0, bottom: 0, left: 15},
            source: {
                size: {width: 392, height: 195},
                columns: 7,
                rows: 3
            }
        },
        portrait: {
            width: 56,
            height: 65,
            margin: {top: 45, right: 0, bottom: 0, left: 40},
            source: {
                size: {width: 392, height: 195},
                columns: 7,
                rows: 3
            }
        }
    },
    details: {
        spacing: -4,
        addressSpacing: 4,

        h1: {
            weight: "Font.Normal",
            capitalization: "Font.Capitalize",
            color: "#FFFFFF"
        },
        h2: {
            weight: "Font.Normal",
            capitalization: "Font.MixedCase",
            color: "#D4D4D4"
        },
        h3: {
            weight: "Font.Normal",
            capitalization: "Font.MixedCase",
            color: "#D4D4D4"
        },

        landscape: {
            h1: { size: 36 },
            h2: { size: 26 },
            h3: { size: 26 },
            margin: {top: 32, right: 10, bottom: 20, left: 5}
        },
        portrait: {
            h1: { size: 36 },
            h2: { size: 26 },
            h3: { size: 26 },
            margin: {top: 42, right: 20, bottom: 10, left: 10}
        }
    },
    distance: {
        weight: "Font.Normal",
        size: 42,
        capitalization: "Font.MixedCase",
        color: "#282828"
    }
};

// Volume Control
var VolumeControl = {
    color: "Qt.rgba(0,0,0,0.8)",
    steps: 50,
    unset: {
        color: "#FFFFFF"
    },
    set: {
        color: "#1282de"
    },
    landscape: {
        width: 502,
        height: 70,
        steps: {
            size: 8,
            space: 2,
            radius: 3
        }
    },
    portrait: {
        width: 70,
        height: 502,
        steps: {
            size: 8,
            space: 2,
            radius: 3
        }
    },
    label: {
        font: {
            size: 26,
            color: "#FFFFFF"
        }
    }
};

// progress spinner
var Spinner = {
    width: 98,
    height: 98,
    uri: "spinnerOnBlack.gif"
};

var SmallSpinner = {
    uri: "spinner_inputfield.gif"
}

var CheckBox = {
    checked: {
        icon: {
            uri: imagePath + "checkboxes/cb_selected.png"
        }
    },
    unchecked: {
        icon: {
            uri: imagePath + "checkboxes/cb_normal.png"
        }
    },
    disabledUnchecked: {
        icon: {
            uri: imagePath + "checkboxes/cb_normal.png"
        }
    },
    disabledChecked: {
        icon: {
            uri: imagePath + "checkboxes/cb_active_disabled.png"
        }
    },
    pressed: {
        icon: {
            uri: imagePath + "checkboxes/cb_pressed.png"
        }
    },
    font: {
        size: 12,
        color: "#222222"
    }

};

var RadioButton = {
    checked: {
        icon: {
            uri: imagePath + "radiobuttons/rb_selected.png"
        }
    },
    unchecked: {
        icon: {
            uri: imagePath + "radiobuttons/rb_normal.png"
        }
    },
    disabledUnchecked: {
        icon: {
            uri: imagePath + "radiobuttons/rb_normal.png"
        }
    },
    disabledChecked: {
        icon: {
            uri: imagePath + "radiobuttons/rb_active_disabled.png"
        }
    },
    pressed: {
        icon: {
            uri: imagePath + "radiobuttons/rb_pressed.png"
        }
    },
    font: {
        size: Button.font.size,
        color: "#222222"
    }
};

var ButtonItem = {
    checked: {
        icon: {
            uri: ""
        }
    },
    unchecked: {
        icon: {
            uri: ""
        }
    },
    disabledUnchecked: {
        icon: {
            uri: ""
        }
    },
    disabledChecked: {
        icon: {
            uri: ""
        }
    },
    pressed: {
        icon: {
            uri:""
        }
    },
    line1: {
        font: {
            size: 36,
            colorActive: "#FFFFFF",
            colorActivePressed: "#1080dd",
            colorDisabled: "#BBBBBB",
            family: "Nokia Pure Text"
        }
    },
    line2: {
        font: {
            size: 26,
            colorActive: "#d4d4d4",
            colorActivePressed: "#1080dd",
            colorDisabled: "#BBBBBB",
            family: "Nokia Pure Text"
        }
    },
    backGroundImage:{
        show: true
    },
    arrowImage: {
        normal: imagePath + "arrow_list_item.png",
        pressed: imagePath + "ButtonItemArrow_pressed.png",
    },
    bgColorPressed: "#464646",
    height: 130
};

var ListItem = {
    height: 130,
    line1: {
        font: {
            size: 36,
            color: "#FFFFFF",
            family: "Nokia Pure Text"
        }
    },
    line2: {
        font: {
            size: 26,
            color: "#D4D4D4",
            family: "Nokia Pure Text"
        }
    }
};

var About = {
    logo: {
        uri: imagePath + "ovi-logo.jpg"
    },
    nav2: {
        uri: imagePath + "copyrights/about_nav2.png"
    },
    navteq: {
        uri: imagePath + "copyrights/about_navteq.png"
    }
}

var Dialog = {
    background: {
        color: "#000000"
    },
    text: {
        color: "#FFFFFF",
        size: 36
    }
}

var Minimap = {
    destination: {
        icon: {
            uri: "../resources/preview_destination.png"
        }
    },
    dayCoverColor: "#fbfaf6",    //c
    nightCoverColor: "#414141",  //c
    sateliteCoverColor: "#3d4820"   //c
}

var RecentSearchListItem  = {
    background: {
        plain : "listbg_plain.png",
        pressed: "#464646"
    },
    text: {
        color: "#ffffff",
        size: 38
    }
}

var ScrollPositionIndicator = {
    background: {
        color: "white",
        opacity: 0
    },
    indicator: {
        color: "#999",
        opacity: 0.8
    }
}

var SearchBox = {
    background: {
        active: "../resources/searchBoxBorderActive.png",
        normal: "../resources/searchBoxBorderNormal.png",
        disabled: "../resources/searchBoxBorderDisabled.png"
    },
    icon: {
        uri: "../resources/searchBoxIcon.png"
    },
    clearIcon: {
        uri: "../resources/searchBoxClearIcon.png"
    }
}

var NavigtionVoiceSettings = {
    footer_leftMargin: 16,
    footer_rightMargin: 16,
    footer_height: 130
}

var VoiceDownloadPage = {
    delegate_height: 130,
    delegate_leftMargin: 16,
    delegate_rightMargin: 16,

    downloadIcon_uri: "../resources/voicedownloads/download.png",
    downloadIconInactive_uri: "../resources/voicedownloads/download_inactive.png",
    downloadIcon_width: 40,
    downloadIcon_height: 40,
    downloadIcon_rightMargin: 5,

    cancelMouseAreaWidth: 70, //VoiceDownloadPage.downloadIcon_width + 30,
    cancelMouseAreaHeight: 70, //VoiceDownloadPage.downloadIcon_height + 30,
    cancelActiveColor: "#105687",

    size_rightMargin: 5,

    hasUpdateIcon_uri: "../resources/voicedownloads/update.png",
    hasUpdateIconInactive_uri: "../resources/voicedownloads/update_inactive.png",
    hasUpdateIcon_width: 40,
    hasUpdateIcon_height: 40,
    hasUpdateIcon_rightMargin: 5,

    progressBar_height: 10,
    progressBar_bottomMargin: 10,

    installingText_rightMargin: 5,

    selectedIndicator_width: 10,

    cancelIcon_uri: "../resources/voicedownloads/cancel.png",
    cancelIconPressed_uri: "../resources/voicedownloads/cancel.png",//"../resources/voicedownloads/cancel_down_state.png",

    activedItemBGColor: "#444",

    progressbarIndicator_uri: "../resources/voicedownloads/progress_bar.png",
    progressbarBackground_uri: "../resources/voicedownloads/progress_bar_bg.png",

    line2color: "#fff"
}

var nps = {
    headline_color: "#fff",
    headline_size: 30,
    headline_family: "Nokia Pure Text",

    portrait: {
        left_margin: 16,
        right_margin: 16,
    },
    landscape: {
        left_margin: 20,
        right_margin: 20,
    },
    progress_value_size: 22,
    progress_value_color: "#282828",
    progress_value_family: "Nokia Pure Text Light",
    progress_value_source: "../resources/slidervalue.png",
    progress_value_width: 42,
    //progress_value_height: 31,

    progress_value_arrow_source: "../resources/slidervaluearrowdown.png",
    progress_value_arrow_bottommargin: 5,

    progress_nobe_width: 42,
    progress_nobe_height: 43,
    progress_nobe_toucharea_width: 100,
    progress_nobe_toucharea_height: 100,
    progress_nobe_source: "../resources/sliderhandle.png",
    progress_nobe_source_down: "../resources/sliderhandlepressed.png",

    theone_bottommargin: 5,
    theone_size: 24,
    theone_family: "Nokia Pure Text",
    theone_color: "#fff",

    theten_bottommargin: 5,
    theten_size: 24,
    theten_family: "Nokia Pure Text",
    theten_color: "#fff",

    notlikely_size: 24,
    notlikely_family: "Nokia Pure Text Light",
    notlikely_color: "#fff",
    notlikely_topmargin: 5,

    likely_size: 24,
    likely_family: "Nokia Pure Text Light",
    likely_color: "#fff",
    likely_topmargin: 5,

    tellus_size: 24,
    tellus_family: "Nokia Pure Text",
    tellus_color: "#fff",
    tellus_color_disabled: "#808080",

    comments_default_height: 88,
    comments_input_color: "#191919",
    comments_input_family: "Nokia Pure Text",
    comments_input_size: 24,

    contact_email_color: "#fff",
    contact_email_color_disabled: "#808080",
    contact_email_family: "Nokia Pure Text",
    contact_email_size: 24,

    email_input_default_height: 60,
    email_input_color: "#191919",
    email_input_family: "Nokia Pure Text",
    email_input_size: 24,

    checkbox_height: 60,
    checkbox_width: 60,
    checkbox_label_leftmargin: 16,
    checkbox_label_color: "#fff",
    checkbox_label_color_disabled: "#808080",
    checkbox_label_family: "Nokia Pure Text Light",
    checkbox_label_size: 24,

    privacy_color: "#fff",
    privacy_color_disabled: "#808080",
    privacy_family: "Nokia Pure Text Light",
    privacy_size: 24,

    send_color: "#fff",
    send_color_disabled: "#808080",
    send_family: "Nokia Pure Text Bold",
    send_size: 30,
    send_width: 400,
    send_height: 88,

    bottom_margin: 30
}
