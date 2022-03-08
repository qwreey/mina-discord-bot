import sys
import asyncio
import json
from download import download

stdout = sys.stdout

def processLine(line):
    try:
        decoded = json.loads(line)
    except Exception as e: stdout.write(json.dumps({'err': str(e)}))
    else:
        nonce = decoded.get('o')
        data = decoded.get('d')
        try:
            downloaded = asyncio.run(asyncio.wait_for(download(
                data.get('url'),
                data.get('noDownload') or False,
                data.get('file')
            ), timeout=60))
        except asyncio.TimeoutError:
            downloaded = 'ERR:TIMEOUT'
        stdout.write(json.dumps({
            'o': nonce,
            'd': downloaded
        }))
        stdout.write("\n")
        stdout.flush()
