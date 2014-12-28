TwoKinds Reader
==============
With this application you'll be able to read TwoKinds in a native client (Because, you know, having a native client is nice).
Also, you can bookmark pages and give them descriptions.

I know it's far from impressive, but you'll get to enjoy the comic in an application instead of having to open the browser, look for the TwoKinds page in your favorites / type the URL, and, in case you want to read the archive, click on archive and select the page you want... That's just too much work, don't you think?

Also, Flora will get mad at you if you don't at least try it out...

~~Please notice me, Tom-sempai~~

Requirements
--------------
This application requires ```Qt 5.3``` (Don't think version 5.3 is really required, but no other version was tested yet).

The following libraries are also required: ```sqlite3```, ```curl``` and ```tidy```.

Super quick and easy tutorial of justice for compiling
--------------
Skip this part if you already know how to compile or just hated the title. 
Seriously now, this is aimed for *somewhat* begginers who still want to compile (Maybe for the lack of a binnary version? =P).

QtCreator (Mostly Windows users doing this):  ```Open project using QtCreator```,  ```Switch to Release mode```, ```Build project```.

Terminal (Linux, Cygwin, Mac, etc.): ```qmake -o Makefile TKReader2.pro ``` followed by  ```make ```.

Both methods should produce an executable inside the code folder (or some folder near it, when using the QtCreator method).

<b>Note for users who are experiencing the following error:</b>
  ```
  In file included from ..\TKReader2\main.cpp:9:0:
  
..\TKReader2\common.h:21:9: error: 'u_int8_t' does not name a type
 typedef u_int8_t  u8;
         ^
         
..\TKReader2\common.h:22:9: error: 'u_int16_t' does not name a type
 tydedef u_int16_t u16;
         ^

..\TKReader2\common.h:23:9: error: 'u_int32_t' does not name a type
 typedef u_int32_t u32;
         ^

..\TKReader2\common.h:24:9: error: 'u_int64_t' does not name a type
 typedef u_int64_t u64;
         ^
  ```
  
  The code at ```common.h, lines 21-24``` must be changed to:
  ```
typedef uint8_t  u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
  ```
  
  My apologies for the inconvenience.

Copyright notices
--------------

PugiXML ©2006-2014 Arseny Kapoulkine (See LICENSE.PugiXML)

TwoKinds and all associated art ©2003-2014 Tom Fischbach (See http://twokinds.keenspot.com/)
