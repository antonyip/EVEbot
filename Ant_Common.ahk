DebugStringToFile(fileName, ByRef aInput)
{
    f := FileOpen(fileName,"w")
    i := 1
    f.Write(aInput)
    f.Close()
    Stdout(Format("WroteTo {1:s}!", fileName))
}

DebugArrayToFile(fileName, ByRef aInput)
{
    f := FileOpen(fileName,"w")
    i := 1
    while(i < (aInput[1] * aInput[2])) 
    {
        myString := Format("{1:d} ", aInput[i])
        f.Write(myString)
        i := i + 1
    }
    f.Close()
    Stdout(Format("WroteTo {1:s}!", fileName))
}

Ant_LoadSignature(fileName)
{
    returnArray := []
    f := FileOpen(fileName,"r")
    while (TextLine := f.ReadLine())
    {
        returnArray.Push(TextLine)
    }
    f.Close()
    return returnArray
}

Ant_CaptureScreenToArray(x,y,w,h)
{
    FinalWidth := w
    FinalHeight := h
    myArray := [FinalWidth, FinalHeight]
    pBitmap := Gdip_BitmapFromScreen()
    if (pBitmap != -1)
    {
        hCounter := y
        while(hCounter < y+h)
        {
            wCounter := x
            while (wCounter < x+w)
            {
                ;PixelGetColor, myColor, wCounter, hCounter
                myColor := Gdip_GetPixel(pBitmap, wCounter, hCounter)
                myArray.Push(myColor)
                if (myColor == 0)
                {
                    Stdout(Format("Time Started {1:s} Ended: {2:s}" , myTimeStarted, A_Now))
                    Stdout("no color extracted")
                    ExitApp
                }
                wCounter := wCounter + 1
            }
            hCounter := hCounter + 1
        }
    }
    Else
    {
        Stdout("Capture failed!")
    }
    GDIP_DisposeImage(pBitMap)
    return myArray
}

Ant_PrintArrayToString(ByRef aInput)
{
    returnString := Format("{1:d}", aInput[1])
    returnString .= "`n"
    returnString .= Format("{1:d}", aInput[2])
    returnString .= "`n"
    length := aInput[1] * aInput[2]
    iter := 3
    while (iter < length + 3)
    {
        returnString .= Format("{1:d} `n", aInput[iter])
        iter := iter + 1
    }
    return returnString
}

Ant_CaptureScreenToArrayUsingArray(ByRef aInput)
{
    return Ant_CaptureScreenToArray(aInput[1],aInput[2],aInput[3],aInput[4])
}

intparse(str) {

	str = %str% ; removes formatting

	Loop, Parse, str ; parse through each character

		If A_LoopField in 0,1,2,3,4,5,6,7,8,9,.,+,-

			int = %int%%A_LoopField% ; build integer

	Return, int + 0.0 ; returns real number

}