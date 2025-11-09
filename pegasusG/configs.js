.pragma library
.import "./constants.js" as CONSTANTS

function setMainColour(newColour, api) { 
     api.memory.set(CONSTANTS.MAIN_COLOUR, newColour) 
}

function setMainSound(newSound, api) {
    api.memory.set(CONSTANTS.MAIN_SOUND, newSound)
}

function setMainTextsize(newTextsize, api) {
    api.memory.set(CONSTANTS.MAIN_TEXTSIZE, newTextsize)
}

function setMainTop(newTop, api) {
    api.memory.set(CONSTANTS.MAIN_TOP, newTop)
}

function setMainRight(newRight, api) {
    api.memory.set(CONSTANTS.MAIN_RIGHT, newRight)
}

function setMainBacksound(newBacksound, api) {
    api.memory.set(CONSTANTS.MAIN_BACKSOUND, newBacksound)
}

const getMainColour = function (api) { 
     let mainColour = api.memory.get(CONSTANTS.MAIN_COLOUR) 
     if (!mainColour) { 
         mainColour = CONSTANTS.DEFAULT_MAIN_COLOUR 
         setMainColour(mainColour, api) 
     } 
     if (mainColour[0] != '#') mainColour = CONSTANTS[mainColour] || mainColour 
     return mainColour 
}

const getMainTextsize = function(api) {
    let mainTextsize  = api.memory.get(CONSTANTS.MAIN_TEXTSIZE)
    if(!mainTextsize){
        mainTextsize = CONSTANTS.DEFAULT_MAIN_TEXTSIZE
        setMainTextsize(mainTextsize, api)
    }
    if(mainTextsize[0] != '#') mainTextsize = CONSTANTS[mainTextsize] || mainTextsize
    return mainTextsize
}

const getMainSound = function(api) {
    let mainSound  = api.memory.get(CONSTANTS.MAIN_SOUND)
    if(!mainSound){
        mainSound = CONSTANTS.DEFAULT_MAIN_SOUND
        setMainSound(mainSound, api)
    }
    if(mainSound[0] != '#') mainSound = CONSTANTS[mainSound] || mainSound
    return mainSound
}

const getMainTop = function(api) {
    let mainTop  = api.memory.get(CONSTANTS.MAIN_TOP)
    if(!mainTop){
        mainTop = CONSTANTS.DEFAULT_MAIN_TOP
        setMainTop(mainTop, api)
    }
    if(mainTop[0] != '#') mainTop = CONSTANTS[mainTop] || mainTop
    return mainTop
}

const getMainRight = function(api) {
    let mainRight  = api.memory.get(CONSTANTS.MAIN_RIGHT)
    if(!mainRight){
        mainRight = CONSTANTS.DEFAULT_MAIN_RIGHT
        setMainRight(mainRight, api)
    }
    if(mainRight[0] != '#') mainRight = CONSTANTS[mainRight] || mainRight
    return mainRight
}

const getMainBacksound = function(api) {
    let mainBacksound  = api.memory.get(CONSTANTS.MAIN_BACKSOUND)
    if(!mainBacksound){
        mainBacksound = CONSTANTS.DEFAULT_MAIN_BACKSOUND
        setMainBacksound(mainBacksound, api)
    }
    if(mainBacksound[0] != '#') mainBacksound = CONSTANTS[mainBacksound] || mainBacksound
    return mainBacksound
}

function getThemeColor(api) {
    const theme = api.memory.get('main_top') || CONSTANTS.DEFAULT_MAIN_TOP;
    return CONSTANTS.THEME_COLORS[theme] || CONSTANTS.THEME_COLORS[CONSTANTS.DEFAULT_MAIN_TOP];
}