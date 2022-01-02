
# What this this?

이 폴더의 개채들은 discordia 와 같은 라이브러리에 패치사항을 injecting 시켜 적용하는  
코드들이 담겨있습니다, **이 코드의 편집은 심한경우 봇에 치명적인 오류를 일으킵니다!**  
따라서 주의가 필요합니다.  

작동 원리는 다음과 같습니다  
modify 된 라이브러리를 dofile 하여 로드합니다, 그 후 package.loaded 에 injecting 하면  
require 할 때 그 inject 된 오브젝트를 불러오게 됩니다  
이것은 require 시스템의 캐싱 원리를 이용한것입니다  
여기서 dofile 을 사용하는 이유는 첫째로써, require 을 하게 되면 package.loaded 에 불필요한  
캐시가 남기 때문에 이런 불필요한 캐시를 남기지 않기 위해서 사용됩니다  
