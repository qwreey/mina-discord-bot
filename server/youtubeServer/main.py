
# {"o":"asdfasdf","d":{"url":"https://www.youtube.com/watch?v=esaeuzXIr-4","file":"asdf"}} 

import json
import sys
import threading
import asyncio
from yt_dlp import YoutubeDL

async def download(url,noDownload,file):
    ydl_opts = {
        'format': 'bestaudio',
        'noprogress': True,
        'quiet': True,
        'no_warnings': True,
        'simulate': noDownload,
        'cachedir': 'data/youtubeCache',
        'outtmpl': file
    }
    with YoutubeDL(ydl_opts) as ydl:
        return ydl.download([url])

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
        }))

for line in sys.stdin:
    thread = threading.Thread(target=processLine, args=(line,))
    thread.start()
