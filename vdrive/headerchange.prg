(
  " CHANGE DISKETTE HEADER-NAME" P  " DISK UNIT NR (8-15) ? 8 "; v  U:  U³8 ° U±15 §  "":  20 (  " DISK DRIVE NR (0/1) ? 0"; Á2  D:  D³0 ° D±1 §  "":  40 ñ<  " PUT TARGET DISK IN UNIT";U;" DRIVE";D 	F  " THEN PRESS ANY KEY TO CONTINUE" /	P ¡ X$:  X$²""§ 80 R	Z A²1: V²16: Q$²Ç(34): P$²Ç(160) r	d T²18: S²0: I$²"I"ªÉ(Ä(D),1) 	n  1,U,15,I$:  350 «	x  310: F$²H$: ¡#2,X$,X$,A$,B$ Õ	  " CURRENT HEADER-NAME ";Q$;F$;Q$ ö	  " DISKETTE ID IS:  ";A$;B$ '
  " NEW NAME (MAX 16 CHARACTERS) OR 'QUIT'" V
   " ? QUIT";N$: L²Ã(N$):  L±V § 130 v
ª  N$²"QUIT" §  "";:  370 ª
´  " OK TO WRITE NEW HEADER-NAME (Y/N) ? Y"; Ä
¾  X$:  X$³±"Y" § 130 Ô
È  L²V § 220 ñ
Ò  X²LªA ¤ V: N$²N$ªP$:  Ü 1,"B-P:";2;144: 2,N$; )æ 1,"U2:";2;D;T;S:  350 ?ð 1,I$:  350:   2 cú  " OLD HEADER-NAME ";Q$;F$;Q$ w 310:   2:   1  " NEW HEADER-NAME ";Q$;H$;Q$ Ë " CHANGE ANOTHER DISKETTE (Y/N) ? Y"; ã" X$:  X$²"Y" § 60 ñ, "";:  6 2,U,2,"#":  350: H$²"" +@1,"U1:";2;D;T;S:  350 JJ1,"B-P:";2;144:  X²A ¤ V eT¡#2,T$: H$²H$ªT$: :  ^1,E,M$,J,K: E²0 §  h " ERROR: ";E;M$;J;K ªr  2:   1:    