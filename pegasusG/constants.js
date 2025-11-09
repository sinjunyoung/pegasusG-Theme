.pragma library
const
    FOREGROUND_LIGHT = "#ffffff",
    
    AVAILABLE_COLOURS = [
        '무작위',
        'genshin01',
        'ani01', 'ani02', 'ani03',
        'game01', 'game02', 'game03', 'game04', 'game05', 'game06',
        'steamgirl01',
    ],
    
    DEFAULT_MAIN_COLOUR = '무작위',
    
    AVAILABLE_SOUNDS = [
        '게임소리',
        '음소거',
    ],
    
    DEFAULT_MAIN_SOUND = '게임소리',
    
    AVAILABLE_TEXTSIZES = [
        '글자크기1',
        '글자크기2',
        '글자크기3',
        '글자크기4',
        '글자크기5',
        '글자크기6',
        '글자크기7',
        '글자크기8',
    ],
    
    글자크기1 = ".8",
    글자크기2 = ".85",
    글자크기3 = ".9",
    글자크기4 = ".95",
    글자크기5 = "1.0",
    글자크기6 = "1.2",
    글자크기7 = "1.4",
    글자크기8 = "1.6",
    
    DEFAULT_MAIN_TEXTSIZE = '글자크기4',
    
    THEME_COLORS = {
        '검정': '#1a1a1a',
        '남색': '#0f1f3d',
        '자주': '#2d1b3d',
        '녹색': '#1a2f1a',
        '벽돌': '#60051a',
        '회색': '#2c3e50',
        '청록': '#004d40',
        '인디고': '#3f51b5',
        '올리브': '#555d48',
        '숯색': '#34495e',
        '짙은하늘': '#00838f',
        '갈색': '#3e2723',
        '보라': '#4a148c',
        '진파랑': '#1a237e',
        '먹색': '#212121'
    },
    
    AVAILABLE_TOPS = Object.keys(THEME_COLORS),
    
    DEFAULT_MAIN_TOP = '검정',
    
    AVAILABLE_RIGHTS = [
        '미리보기',
        '숨기기',
    ],
    
    미리보기 = "true",
    숨기기 = "false",
    
    DEFAULT_MAIN_RIGHT = '미리보기',
    
       
    MAIN_COLOUR = 'main_colour',
    MAIN_SOUND = 'main_sound',
    MAIN_TEXTSIZE = 'main_textsize',
    MAIN_TOP = 'main_top',
    MAIN_RIGHT = 'main_right',
    HIDE_SUPPORT = 'hide_support'