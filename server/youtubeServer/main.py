
import json
import sys
import asyncio

async def download(url,noDownload,file):
    return True

async def main(line):
    try:
        decoded = json.loads(line)
    except Exception as e: print(json.dumps({'err': e}))
    else:
        nonce = decoded.get('o')
        data = decoded.get('d')
        print(json.dumps({
            'o': nonce,
            'd': await download(
                data.get('url'),
                data.get('noDownload') or False,
                data.get('file')
            )
        }))

for line in sys.stdin:
    asyncio.run(main(line))
