#include <stdio.h>
#include <conio.h>

// lua 로 getch 기능을 넘기는 확장
// 키가 입력되기 까지 개속 기다린다
// local key do
//     local keyinput = io.popen("this");
//     key = keyinput:read("*all");
//     keyinput:close();
// end

int main() {
    int key; // key 변수를 지정한다
    key = getch(); // 키 인풋을 하나 가져온다
	
	if (key == 0x00 || key == 0xE0) { // 확장키를 핸들링한다 ( || 는 or 를 의미함)
		int extKey;
		extKey = getch(); // 키 하나를 더 받아온다 (확장키는 두번 받아와야 함)
		printf("%dE%d",key,extKey); // 예 : 방향키 위로 244E72
	} else { // 확장키가 아닌경우
		printf("%dA",key); // 해당 값을 std output 으로 넘긴다
		// 예 : a 는 
	}
	
	return 0;
}