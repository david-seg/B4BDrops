#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; settings
b4bMenuBtn = I 	
global debugMousePos = true
global sleepBetweenCommands := 20

; Hot Keys
; Copper
~Numpad0::
HandleInput(700, 875)
return

; Pistol/SMG
~NumpadDot::
HandleInput(800, 875)
return

; LMG
~Numpad1::
HandleInput(1000, 875)
return

; Sniper
~Numpad2::
HandleInput(1100, 875)
return

; Shotty
~Numpad3::
HandleInput(1300, 875)
return

; Offensive
~Numpad4::
HandleInput(700, 700)
return

; Support
~Numpad5::
HandleInput(1000, 700)
return

; Quick
~Numpad6::
HandleInput(1200, 700)
return


HandleInput(mouseX, mouseY)
{
	If (WinActive("Back 4 Blood"))					; check if we are in B4B
	{
		key := StrReplace(A_ThisHotKey, "~")		; trim the current trigger
		successResponse = EndKey:%key%				; create a multi input response check
		dropCount := 1								; set the initial drop count to 1
		isRClick := false							; assume more inputs are comming
		
		KeyWait, %key%, T.3							; check for key release
		If (ErrorLevel == 1)						; Error means we held the key longer than timeout
			isRClick := true					
		Else										; Otherwise check for additional key hits
		{
			isReadingInput := true
			While (isReadingInput == true)
			{
				Input, inputVar, L2 T.3, {%key%}	; wait for additional key inputs, use key as a terminating value
				If (ErrorLevel == successResponse)	; key was read
					dropCount += 1					; increment drop count
				Else								; key was not release
					isReadingInput = false			; stop looping
			}
		}
		
		KeyWait, %key%								; wait for key release, if key is held.  Prevents additional triggers
		
		Drop(mouseX, mouseY, isRClick, dropCount) 	; call the drop method
	}
}

Drop(mouseX, mouseY, isRClick, dropCount)
{
	global b4bMenuBtn
	
	BlockInput On									; prevent additional inputs
	
	Send %b4bMenuBtn%								; open menu
	Sleep %sleepBetweenCommands%					; sleep so the menu has time to open
	
	; MouseClick has a X,Y input but the clicks where 
	; happening faster than the menu control was registring 
	; the mouse hover.  Using 2 seperate commands fixed 
	; this issue. it also lets us check the mouse position
	; if we only want to see where the mouse lands.
	MouseMove, mouseX, mouseY						; move mouse to x,y window location
	Sleep %sleepBetweenCommands%					; sleep so the mouse has time to trigger the menu control
	
	If (debugMousePos)
		return										; we only want to see where the mouse ended up
	
	If (isRClick)
		MouseClick, right							; drop all
	Else
		MouseClick, left,,, dropCount				; drop the counted amount
		
	Sleep %sleepBetweenCommands%					; sleep to let B4B handle the inputs
	Send %b4bMenuBtn%								; close menu
	Sleep %sleepBetweenCommands%					; iono if this sleep is necessary anymore?
	
	BlockInput Off									; stop blocking inputs so we can play again
}