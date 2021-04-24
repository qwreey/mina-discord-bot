--Qeact = require("Qeact"); FrameEl = Qeact.importElement("Frame"); print(Qeact:strRender( FrameEl {Text = "Hello",New = FrameEl {Text = "world"}} ));

-- LUA 에서 선언형 프로그래밍

Qeact = require(game and game.ReplicatedStorage:WaitForChild("rojo"):WaitForChild("Qeact") or "../Qeact");
FrameEl = Qeact.importElement("Frame"); -- 프레임 사용을 선언
TextButtonEl = Qeact.importElement("TextButton"); -- 텍스트 버튼 사용을 선언

UDim2 = UDim2 or {
    new = function (ScX,OfX,ScY,OfY)
        return ("{%s, %s, %s, %s}"):format(ScX,OfX,ScY,OfY);
    end;
}

local e = FrameEl { -- 프레임을 만듬
    Size = UDim2.new(1,0,1,0); -- 크기를 1,0,1,0 으로 지정
    New = TextButtonEl { -- 그 안에 텍스트를 하나 더 만듬
        Text = "world"; -- 텍스트를 world 로 지정
        Size = UDim2.new(0,25,0,25);
        WhenCreated = function (this)
            -- 이 함수는 rbxRender 가 동작할 때 이루워짐
            print(this); -- 이 텍스트를 프린트함
        end;
        MouseButton1Click = function ()
            print("마우스가 클릭됨");
        end;
    };
};

print(Qeact:strRender(e)); -- 디버깅을 위한 글자 렌더링
Qeact:rbxRender(e,workspace); -- 렌더 시작 (테이블 => 개체)
