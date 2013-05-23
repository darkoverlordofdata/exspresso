1	PRINT "DO YOU WANT INSTRUCCIONS ON LP0" :
	INPUT "TYPE YES FOR 'LP0' OUTPUT";A$:
	IF A$="YESE" THEN A$="LP0:" ELSE A$="KB:"
2	OPEN A$ FOR OUTPUT AS FILE 1
10 PRINT #1% "THESE ARE THE INSTRUCTIONS FOR PLAYING THE GAME STARTREK"
11 PRINT #1%
12 PRINT #1%
20 PRINT #1% "FIRST YOUR CHOICES OF COMMANDS ARE:"
21 PRINT #1%
22 PRINT #1%
30 PRINT #1% "     "0" - SET COURSE "
40 PRINT #1% "     "1" - SHORT RANGE SENSOR SCAN"
50 PRINT #1% "     "2" - LONG RANGE SENSOR SCAN"
60 PRINT #1% "     "3" - FIRE PHASERS"
70 PRINT #1% "     "4" - FIRE PHOTON TORPEDOES"
80 PRINT #1% "     "5" - DAMAGE CONTROL REPORT"
81 PRINT #1% "     "6" - LIST THE COMMANDS"
90 PRINT #1%
100 PRINT #1% " WHEN YOU ARE ASKED FOR THE COURSE YOU MUST RESPOND WITH"
101 PRINT #1%
110 PRINT #1% " A NUMBER WHICH CORRESRONDS TO AN ANGLE IN WHICH "
111 PRINT #1%
120 PRINT #1% " YOU WISH TO TRAVEL.  PLOTTED BELOW IS A GRAPH OF THE"
121 PRINT #1%
130 PRINT #1% " DIRECTIONS AND THEIR ANGLES:"
131 PRINT #1%
140 PRINT #1% "          0"
141 PRINT #1% "          I"
142 PRINT #1% "     270<<E>>090"
143 PRINT #1% "          I"
144 PRINT #1% "         180"
145 PRINT #1% 
146 PRINT #1%
150 PRINT #1% " ON A SHORT RANGE SCAN YOU WILL FIND THE LAYOUT OF THE"
151 PRINT #1%
160 PRINT #1% " STARS(*), STARBASES(B), KLINGON SHIPS(K), AND THE"
161 PRINT #1% 
170 PRINT #1% " ENTERPRISE(E)."
171 PRINT #1%
180 PRINT #1% " ON A LONG RANGE SCAN YOU WILL FIND THE NUMBER OF STARS,"
181 PRINT #1%
190 PRINT #1% " STARBASES, AND THE NUMBER OF KLINGONS IN THAT QUADRANT."
191 PRINT #1%
200 PRINT #1% " BELOW IS A EXAMPLE OF ONE OF THE BLOCKS IN A SCAN:"
201 PRINT #1% 
202 PRINT #1%
210 PRINT #1% "     111"
211 PRINT #1% "     III"
212 PRINT #1% "     III>>>>>>> NUMBER OF STARS"
213 PRINT #1% "     II"
214 PRINT #1% "     II>>>>>>>> NUMBER OF STARBASES"
215 PRINT #1% "     I"
216 PRINT #1% "     I>>>>>>>>> NUMBER OF KLINGONS IN THE QUADRANT"
220 PRINT #1%
230 PRINT #1% 
240 PRINT #1% " BELOW IS THE LAYPUT OF THE GAME BOARD AND EACH OF THE QUADRANT"
241 PRINT #1% 
250 PRINT #1% " NUMBERS. "
251 PRINT #1%
260 PRINT #1% "-------------------------------------------------"
261 PRINT #1% "I     I     I     I     I     I     I     I     I"
262 PRINT #1% "I 1-1 I 1-2 I 1-3 I 1-4 I 1-5 I 1-6 I 1-7 I 1-8 I"
263 PRINT #1% "I     I     I     I     I     I     I     I     I"
264 PRINT #1% "-------------------------------------------------"
265 PRINT #1% "I     I     I     I     I     I     I     I     I"
266 PRINT #1% "I 2-1 I 2-2 I 2-3 I 2-4 I 2-5 I 2-6 I 2-7 I 2-8 I"
267 PRINT #1% "I     I     I     I     I     I     I     I     I"
268 PRINT #1% "-------------------------------------------------"
269 PRINT #1% "I     I     I     I     I     I     I     I     I"
270 PRINT #1% "I 3-1 I 3-2 I 3-3 I 3-4 I 3-5 I 3-6 I 3-7 I 3-8 I "
271 PRINT #1% "I     I     I     I     I     I     I     I     I"
272 PRINT #1% "-------------------------------------------------"
273 PRINT #1% "I     I     I     I     I     I     I     I     I"
274 PRINT #1% "I 4-1 I 4-2 I 4-3 I 4-4 I 4-5 I 4-6 I 4-7 I 4-8 I"
275 PRINT #1% "I     I     I     I     I     I     I     I     I"
276 PRINT #1% "-------------------------------------------------"
277 PRINT #1% "I     I     I     I     I     I     I     I     I"
278 PRINT #1% "I 5-1 I 5-2 I 5-3 I 5-4 I 5-5 I 5-6 I 5-7 I 5-8 I"
279 PRINT #1% "I     I     I     I     I     I     I     I     I  "
280 PRINT #1% "-------------------------------------------------"
281 PRINT #1% "I     I     I     I     I     I     I     I     I   "
282 PRINT #1% "I 6-1 I 6-2 I 6-3 I 6-4 I 6-5 I 6-6 I 6-7 I 6-8 I "
283 PRINT #1% "I     I     I     I     I     I     I     I     I "
284 PRINT #1% "-------------------------------------------------"
285 PRINT #1% "I     I     I     I     I     I     I     I     I"
286 PRINT #1% "I 7-1 I 7-2 I 7-3 I 7-4 I 7-5 I 7-6 I 7-7 I 7-8 I"
287 PRINT #1% "I     I     I     I     I     I     I     I     I"
288 PRINT #1% "-------------------------------------------------"
289 PRINT #1% "I     I     I     I     I     I     I     I     I"
290 PRINT #1% "I 8-1 I 8-2 I 8-3 I 8-4 I 8-5 I 8-6 I 8-7 I 8-8 I "
291 PRINT #1% "I     I     I     I     I     I     I     I     I"
292 PRINT #1% "-------------------------------------------------"
293 PRINT #1% 
294 PRINT #1% 
330 	CLOSE 1
340	CHAIN "STRTRK" 5%
350	END
