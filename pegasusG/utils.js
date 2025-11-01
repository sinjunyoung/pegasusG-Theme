// This file contains some helper scripts for formatting data


// For multiplayer games, show the player count as '1-N'
function formatPlayers(playerCount) {
    if (playerCount === 1)
        return playerCount

    return "1-" + playerCount;
}


// Show dates in Y-M-D format
function formatDate(date) {
    return Qt.formatDate(date, "yyyy-MM-dd");
}


// Show last played time as text. Based on the code of the default Pegasus theme.
// Note to self: I should probably move this into the API.
function formatLastPlayed(lastPlayed) {
    if (isNaN(lastPlayed))
        return "never";

    var now = new Date();

    var elapsedHours = (now.getTime() - lastPlayed.getTime()) / 1000 / 60 / 60;
    if (elapsedHours < 24 && now.getDate() === lastPlayed.getDate())
        return "today";

    var elapsedDays = Math.round(elapsedHours / 24);
    if (elapsedDays <= 1)
        return "yesterday";

    return elapsedDays + " days ago"
}


// Display the play time (provided in seconds) with text.
// Based on the code of the default Pegasus theme.
// Note to self: I should probably move this into the API.
function formatPlayTime(playTime) {
    var minutes = Math.ceil(playTime / 60)
    if (minutes <= 90)
        return "게임시간:" + Math.round(minutes) + " 분";

    return "게임시간:" +parseFloat((minutes / 60).toFixed(1)) + " 시간"
}

// utils.js - 유틸리티 함수 모음

// 플랫폼 별칭 매핑
// 동일한 이미지/로고를 사용하는 플랫폼들을 매핑
function getPlatformImageName(shortName) {
    const platformAliases = {
        // Nintendo
        'snes': 'sfc',
        'nes': 'fc',

        // Sony
        'psx': 'ps1',
        'playstation': 'ps1',
        'ps vita': 'psv',
        'psvita': 'psv',
        
        // 필요한 별칭 추가
        // 'new_name': 'existing_folder_name',
    };
    
    return platformAliases[shortName.toLowerCase()] || shortName;
}

// 고유한 게임 값 추출 (필터링용)
function uniqueGameValues(propName) {
    var values = [];
    for (var i = 0; i < api.allGames.count; i++) {
        var game = api.allGames.get(i);
        var prop = game[propName];
        if (prop && prop.length) {
            for (var j = 0; j < prop.length; j++) {
                if (values.indexOf(prop[j]) === -1) {
                    values.push(prop[j]);
                }
            }
        }
    }
    return values.sort();
}