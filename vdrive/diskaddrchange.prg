&d � ============================== Jn �  DRIVE ADDRESS CHANGE PROGRAM ox � FOR USE WITH VIC20, C64, PLUS4 �� � OR C16 WITH ANY CBM DISK DRIVE �� � MOD. 9/84 TEST SYSTEMS DEPT. �� � ============================== �� ��(8)�(142) 	� � "�DRIVE ADDRESS CHANGE PROGRAM 6	� � "TURN OFF ALL DRIVES NOW [	� � "EXCEPT THE ONE TO BE CHANGED. ~	� � "OLD DEVICE ADDRESS  8���"; �	� � OD : � OD�8 � OD�15 � 200 �	� � "NEW DEVICE ADDRESS  9���"; �	� � ND : � ND�8 � ND�15 � 220 �	� � -------------- 
� � DRIVE TYPE IS?  
� -------------- .
� 1,OD,15 e
� 1, "M-R" �(255) �(255) : �# 1, C$ : C��(C$��(0)) t
"� ST � 590 �
,� C�213 � MT�12  : � 4040 V2.1 �
6� C�226 � MT�50  : � 2040 V1.2 �
@� C�241 � MT�1551: � 1551 �
J� C�242 � MT�12  : � 8050 V2.5 T� C�254 � MT�119 : � 2031 V2.6 1^� C��198 � 420 lh: � 1, "M-R" �(234) �(16) : �# 1, ZB$ : ZB��(ZB$��(0)) �r: � ZB�0 � MT�12 : � 4040 V2.7 �|: � ZB��1 � ST � 590 ��: � 1, "M-R" �(172) �(16) : �# 1, ZC$ : ZC��(ZC$��(0)) �: � ZC�1 � MT�12 : � 8050 V2.7 )�: � ZC�2 � MT�12 : � 8250 V2.7 1�� 1 F�� -------------- [�� CHANGE ADDRESS p�� -------------- ��� MT�1551 � 500  : � SPECIAL! ��: � 1,OD,15 ��: � 1, "M-W" �(MT) �(0) �(2) �(ND�32) �(ND�64) ��: � 520 �� � (ND�8 � ND�9) � � "1551 ADDRESS NOT 8 OR 9!" : � 220 ?�: � 1,OD,15, "%"��(�(ND),1 ) G� 1 w� "THE SELECTED DRIVE HAS BEEN CHANGED..." �� "NOW TURN ON THE OTHER DRIVE(S)" �&� �0: ������� �:: ERR� ! �D: ������� �N� "DEVICE ERROR:"; ST �X�   