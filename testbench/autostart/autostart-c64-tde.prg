  � * MAIN . � CHECK IF DRIVE IS PRESENT Z � 1,8,0:� 1: � (ST � 128) � 128 � E � 1 z � "�VICE AUTOSTART TEST":� � � "EXPECTING:" �
 � "TDE:"; 1 ; � � "VDRIVE:"; 0 ; � � "VFS:"; 0 � � "AUTOSTART DISK:"; 0 � � "DISK IMAGE:"; 0 � � 	 � E � 1 � � 90 	 � 1000 +	 � "MSG:";PU$ 6	 � 2000 G	 � "DIR:";DI$ [	  � "DISKID:";ID$ o	Z � "NO DRIVE:";E z	\ � 3000 �	^ � �	` � 4000 �	b � F � 0 � � 55295 , 0: � 53280, 5: � "ALL OK" �	d � F �� 0 � � 55295 , 255: � 53280, 2: � "FAILED" �	f � 
�� * GET POWERUP MESSAGE FROM DRIVE 2
�� 15,8,15,"UI" D
��15,A,PU$,C,D M
�� 15 S
�� u
�� * GET HEADER FROM DIRECTORY �
�� 1,8,0,"$":DI$�"": ID$�"": � ST �� 0 � � �
�� I � 0 � 7: �#1, A$: �
�� ST �� 0 � � �
�� �
�� I � 0 � 15: �#1, A$: DI$�DI$�A$: � �� #1,A$:� #1,A$ :�� I � 0 � 5: �#1, A$: ID$�ID$�A$: � B�� 1 H�� c�� * CHECK WHAT IS WHAT ��� �(PU$, 7) � "CBM DOS" � TD � 1 : � TDE ENABLED ��� �(PU$, 13) � "VIRTUAL DRIVE" � VD � 1 : � VIRTUAL DRIVE 
�� �(PU$, 7) � "VICE FS" � FS � 1 : � FILESYSTEM a�� �(DI$, 9) � "AUTOSTART" � ID$ �� " #8:0" � AD � 1 : � USING AUTOSTART DISK IMAGE ��� �(DI$, 8) � "TESTDISK" � D � 1 : � USING REGULAR DISK IMAGE ��� ��� "TDE:"; TD ; ��� "VDRIVE:"; VD ; ��� "VFS:"; FS ��� "AUTOSTART DISK:"; AD �� "DISK IMAGE:"; D �� 5�� * CHECK FOR ERRORS ?�F � 0 Y�� TD �� 1 � F � F � 1 s�� VD �� 0 � F � F � 1 ��� FS �� 0 � F � F � 1 ��� AD �� 0 � F � F � 1 ��� D �� 0 � F � F � 1 ��� "ERRORS: "; F ��� ��� PRG AUTOSTART MODES ARE: �� 0 : VIRTUAL FILESYSTEM H�� 1 : INJECT TO RAM (THERE MIGHT BE NO DRIVE) ^�� 2 : COPY TO D64 ��� $90/144: �ERNAL �/� �TATUS �ORD �� ��� ��� +-------+---------------------------------+ ��� \ �IT 7 \ 1 = �EVICE NOT PRESENT (�) \ �� \ \ 1 = �ND OF �APE (�) \ 4�� \ �IT 6 \ 1 = �ND OF �ILE (�+�) \ ]�� \ �IT 5 \ 1 = �HECKSUM ERROR (�) \ ��� \ �IT 4 \ 1 = �IFFERENT ERROR (�) \ ��� \ �IT 3 \ 1 = �OO MANY BYTES (�) \ ��� \ �IT 2 \ 1 = �OO FEW BYTES (�) \ ��� \ �IT 1 \ 1 = �IMEOUT �EAD (�) \ '�� \ �IT 0 \ 1 = �IMEOUT �RITE (�) \ Y�� +-------+---------------------------------+ _�� ��� (�) = �ERIAL BUS, (�) = �APE   