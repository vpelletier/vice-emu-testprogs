d � &e � THIS IS EXAMPLE OF USING @f � DS12C887 FROM BASIC Fg � Rh � A$(7) ji � A�1�7:� A$(A):� A pj : �m � "�DS12C887 RTC TEST" �n � "SELECT BASE ADDRESS:" �o � "1. $D500" �p � "2. $D600" �q � "3. $DE00" �r � "4. $DF00" 	s � 198,0:� 198,1: � A$ H	t � A$ � "1" � BASE�54528:� 130:� BASE ADDRESS OF CHIP (D500) �	u � A$ � "2" � BASE�54784:� 130:� BASE ADDRESS OF CHIP (D600) �	v � A$ � "3" � BASE�56832:� 130:� BASE ADDRESS OF CHIP (DE00) 
w � A$ � "4" � BASE�57088:� 130:� BASE ADDRESS OF CHIP (DF00) 
� � 115 
� � "�" &
� � "" >
� � GET TIME FROM RTC j
� � BASE,6:DW��(BASE�1):� DW � 7 � DW � 0 �
� � BASE,4:H��(BASE�1) �
� � BASE,2:MI��(BASE�1) �
� � BASE,0:S��(BASE�1) �
� � BASE,7:D��(BASE�1) �
� � BASE,8:M��(BASE�1) � � BASE,9:Y��(BASE�1) � V�H:� 1100:� V;"� :"; 6� V�MI:� 1100:� V;"� :"; PV�S:� 1100:� V;"�  "; jV�M:� 1100:� V;"� /"; �V�D:� 1100:� V;"� /"; �V�Y:� 1100:� V;"�  "; �� A$(DW);"        " �	� SETUP CIA1 TOD CLOCK �
: �PM�0:V�H:� 1100:�V�13� 280 V�V�12:� 1000:H�V � 56329,S (� 56328,0 .": E#� THAT'S ALL FOLKS K': U�� 200 y�� CONVERT V TO BCD, RETURN IN V ��V��(V�10)�16�(V�10��(V�10)) ��� �L� CONVERT V FROM BCD, RETURN IN V �VV��(V�16)�10�(V�16��(V�16)) �`� *j� SUNDAY,MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,SATURDAY   