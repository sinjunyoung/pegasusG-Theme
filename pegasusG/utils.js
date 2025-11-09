function formatPlayers(playerCount) {
    if (playerCount === 1)
        return playerCount

    return "1-" + playerCount;
}


function formatDate(date) {
    return Qt.formatDate(date, "yyyy-MM-dd");
}


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

function formatPlayTime(playTime) {
    var time = Number(playTime) || 0;   // 안전한 숫자 변환
    var minutes = Math.floor(time / 60);
    var hours = Math.floor(minutes / 60);

    if (hours > 0) {
        var remainMin = minutes % 60;
        return "게임시간: " + hours + "시간 " + remainMin + "분";
    } else {
        return "게임시간: " + minutes + "분";
    }
}

function getPlatformName(shortName) {
    const platformAliases = {

        '3do': '3DO',

        'dc': 'Dreamcast',
        'dreamcast': 'Dreamcast',
        'gamegear': 'Game Gear',
        'gg': 'Game Gear',
        'md': 'Mega Drive',
        'megadrive': 'Mega Drive',
        'md32x': 'Mega Drive 32X',
        'md-32x': 'Mega Drive 32X',
        'megadrive32x': 'Mega Drive 32X',
        'mdcd': 'Mega Drive CD',
        'md-cd': 'Mega Drive CD',
        'megadrivecd': 'Mega Drive CD',
        'megadrive-cd': 'Mega Drive CD',
        'naomi': 'Sega NAOMI',
        'seganaomi': 'Sega NAOMI',
        'ss': 'Sega Saturn',
        'ws': 'WonderSwan',
        'wsc': 'WonderSwan Color',

        'neogeo': 'Neo Geo',
        'neogeocd': 'Neo Geo CD',
        'ngp': 'Neo Geo Pocket',
        'ngpc': 'Neo Geo Pocket Color',

        'dos': 'DOS',
        'win': 'Windows',
        'windows': 'Windows',

        'msx': 'MSX',
        'msx2': 'MSX2',

        'pce': 'PC Engine',
        'pcengine': 'PC Engine',
        'pcecd': 'PC Engine CD',
        'pce-cd': 'PC Engine CD',
        'turbografx-16': 'PC Engine CD',
        'pcenginecd': 'PC Engine CD',
        'pcengine-cd': 'PC Engine CD',
        'turbografx-cd': 'PC Engine CD',

        'pc98': 'NEC PC-9801',
        'pc-98': 'NEC PC-9801',

        'mame': 'Arcade',
        'fbneo': 'Arcade',
        'arcade': 'Arcade',

        'gb': 'Game Boy',
        'gbc': 'Game Boy Color',
        'gba': 'Game Boy Advance',
        'nes': 'Family Computer',
        'fc': 'Family Computer',
        'snes': 'Super Famicom',
        'sfc': 'Super Famicom',
        'nds': 'NDS',
        '3ds': '3DS',
        'n64': 'Nintendo 64',
        'nintendo64': 'Nintendo 64',
        'nds': 'Nintendo DS',
        'gc': 'Nintendo GameCube',
        'ngc': 'Nintendo GameCube',
        'gamecube': 'Nintendo GameCube',
        'nintendogamecube': 'Nintendo GameCube',
        'wii': 'Wii',
        'wiiu': 'Wii U',
        'nsw': 'Nintendo Switch',

        'ps1': 'PlayStation',
        'psx': 'PlayStation',
        'playstation': 'PlayStation',
        'ps2': 'PlayStation 2',
        'ps3': 'PlayStation 3',
        'psp': 'PlayStation Portable',
        'psv': 'PlayStation Vita',
        'psvita': 'PlayStation Vita',

        'xbox': 'Xbox',
        'xbox360': 'Xbox 360',
        'xboxone': 'Xbox One',

    };

    const key = shortName.trim().replace(/\s+/g, '').toLowerCase();

    return platformAliases[key] || shortName;
}

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