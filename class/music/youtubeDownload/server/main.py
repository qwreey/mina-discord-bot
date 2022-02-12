
# {"o":"asdfasdf","d":{"url":"https://www.youtube.com/watch?v=esaeuzXIr-4","file":"asdf"}} 

# 계속 yt-dlp 프로세스를 새로 만드는건 비효율적인것 같아서
# 아에 파이썬으로 불러온 다음 그걸 IPC 로 돌리는게 더 효율적인거 같아서 (CPU 면에서)
# 파이썬으로 서버를 만들었습니다 

import json
import sys
import threading
import asyncio
from yt_dlp import YoutubeDL

async def download(url,noDownload,file):
    ydl_opts = {
        'format': 'bestaudio/best',
        'noprogress': True,
        'quiet': True,
        'no_warnings': True,
        'simulate': noDownload,
        'cachedir': 'data/youtubeCache',
        'outtmpl': file
    }
    try:
        with YoutubeDL(ydl_opts) as ydl:
            return ydl.extract_info(url,download=(not noDownload))
    except Exception as e: return "ERR:"+str(e)

def processLine(line):
    try:
        decoded = json.loads(line)
    except Exception as e: print(json.dumps({'err': e}))
    else:
        nonce = decoded.get('o')
        data = decoded.get('d')
        try:
            downloaded = asyncio.run(asyncio.wait_for(download(
                data.get('url'),
                data.get('noDownload') or False,
                data.get('file')
            ), timeout=35.0))
        except asyncio.TimeoutError:
            downloaded = 'ERR:TIMEOUT'
        print(json.dumps({
            'o': nonce,
            'd': downloaded
        }),flush=True,end='')

for line in sys.stdin:
    thread = threading.Thread(target=processLine, args=(line,))
    thread.start()