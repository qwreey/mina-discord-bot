from yt_dlp import YoutubeDL

class Timeout(Exception): pass

def downloadHook(data):
    if data['status'] == "downloading" and data['elapsed'] >= 60:
        raise Timeout
downloadHooks = [downloadHook]

async def download(url,noDownload,file):
    ydl_opts = {
        'format': 'bestaudio',
        'noprogress': True,
        'quiet': True,
        'no_warnings': True,
        'simulate': noDownload,
        'cachedir': 'data/youtubeCache',
        'outtmpl': file,
        'continuedl': True,
        'ratelimit': 2900000,
        'progress_hooks': downloadHooks
    }
    try:
        with YoutubeDL(ydl_opts) as ydl:
            return ydl.extract_info(url,download=(not noDownload))
    except Timeout: return "ERR:TIMEOUT"
    except Exception as e: return "ERR:"+str(e)
