json = require("json");

local this = json.decode([[{
    "title": "재생 목록에 있는 곡들은 다음과 같습니다",
    "color": 16040191,
    "footer": {
      "text": "몰라 일단 이상해도 되면 되는거야"
    },
    "fields": [
      {
        "name": "1번 곡",
        "value": "ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㅇㄹ"
      },
      {
        "name": "2번 곡",
        "value": "ㅁㄴㅇㄻㄴㅇㅁㄴㅇㄻㄴㅇㄻㄴㅇㄹ"
      }
    ]
  }]]);

dumpTable = require("libs.dumpTable");
dumpTable.print(this);