https://github.com/xieve/musicord
에서 참고받았습니다

youtube-dl 라이브러리를 사용합니다

<!-- pip install ffprobe/avprobe
pip install ffmpeg/avconv -->
pip install youtube-dl


--buffer-size 16K
--write-info-json
-r 90M
youtube-dl --quiet --write-thumbnail --write-description -o "./data/youtubeFiles/%(id)s.%(ext)s" --geo-bypass --extract-audio --audio-format "mp3" --cache-dir ./data/youtubeCache "https://www.youtube.com/watch/?v=v7bnOxV4jAc"

youtube-dl --q --write-thumbnail --write-description -o "./data/youtubeFiles/%(id)s.%(ext)s" --geo-bypass --x --cache-dir ./data/youtubeCache "https://www.youtube.com/watch/?v=v7bnOxV4jAc"