tasm int77
tlink /t int77.obj
int77
tasm maintp
tasm libtp
tlink maintp libtp
maintp.exe
