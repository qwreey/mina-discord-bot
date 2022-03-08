
# {"o":"asdfasdf","d":{"url":"https://www.youtube.com/watch?v=esaeuzXIr-4","file":"asdf"}} 

# 계속 yt-dlp 프로세스를 새로 만드는건 비효율적인것 같아서
# 아에 파이썬으로 불러온 다음 그걸 IPC 로 돌리는게 더 효율적인거 같아서 (CPU 면에서)
# 파이썬으로 서버를 만들었습니다 

import threading
from processLine import processLine
import sys

for line in sys.stdin:
    thread = threading.Thread(target=processLine, args=(line,))
    thread.start()
