%let pgm=utl-expanding-sas-string-functionality-by-loading-strings-into-the-infile-buffer;

%stop_submission;

This post loads a string variable into the infile buffer allowing access using the powerful sas input statement to parse the buffer.

PROBLEM

Input string operations to parse messy four word  string into name grade and weight

         CONTENTS

           1 sas datastep solution
           2 sas load infile macro

github
https://tinyurl.com/3j3npc6s
https://github.com/rogerjdeangelis/utl-expanding-sas-string-functionality-by-loading-strings-into-the-infile-buffer

stackoverflow r
https://tinyurl.com/23t8r326
https://stackoverflow.com/questions/79447615/splitting-one-column-to-three-columns-for-uneven-characters-in-r

I could get any of the solutions to work. Two solutions use the wrong input;
Also the solutions are not obvious?
I do realize this can be solved easily with sas call scan, find abd substr but I wanted to
demonstate using the infile buffer.

I did not develop this algorithm. I first learned of it from
Bartosz Jablonski who in turn learned of it from someone else.

I hope I have enhanced the algorithm.
Most of my post are the result of standing on the shoulders of others.


/**************************************************************************************************************************/
/*                               |                                                      |                                 */
/*                               |                                                      |                                 */
/*         INPUT                 |  PROCESS                                             |     OUTPUT                      */
/*         =====                 |  =======                                             |     ======                      */
/*                               |                                                      |                                 */
/*  SD1.HAVE                     | 1 SAS DATASTEP SOLUTION                              |                                 */
/*                               | =======================                              | WANT.SAS&BDAT                   */
/*          STR                  |                                                      |                                 */
/*                               | data want;                                           |                                 */
/*  Jhon Austin B 100kg          |   ;                                                  | FIRST LAST   GRADE  WEIGHT      */
/*  Mick Gray C 110kg            |   set sd1.have;                                      |                                 */
/*  Tom Jef A30kg                |                                                      | Jhon  Austin   B     100kg      */
/*                               |   informat first last $8.                            | Mick  Gray     C     110kg      */
/*  options validvarname=upcase; |           therest $24. grade $1.;                    | Tom   Jef      A      30kg      */
/*  libname sd1 "d:/sd1";        |                                                      |                                 */
/*  data sd1.have;               |   * load _infile_ buffer with variable str;          |                                 */
/*    str="Jhon Austin B 100kg"; |   %loadinfile(str);                                  |                                 */
/*      output;                  |                                                      |                                 */
/*    str="Mick Gray C 110kg";   |   input first last therest & @;                      |                                 */
/*       output;                 |                                                      |                                 */
/*    str="Tom Jef A30kg";       |   grade=compress(therest);                           |                                 */
/*      output;                  |   weight=substr(compress(therest),2);                |                                 */
/*  run;quit;                    |                                                      |                                 */
/*                               |   * restart the buffer;                              |                                 */
/*                               |   input @1 @@;                                       |                                 */
/*                               |                                                      |                                 */
/*                               |   keep first last grade weight;                      |                                 */
/*                               | run;quit;                                            |                                 */
/*                               |                                                      |                                 */
/*                               |                                                      |                                 */
/*                               | 2 SAS LOAD INFILE MACRO                              |                                 */
/*                               | =======================                              |                                 */
/*                               |                                                      |                                 */
/*                               | %macro loadinfile(str)                               |                                 */
/*                               |   /des="load string into the infile buffer";         |                                 */
/*                               |  %dosubl('                                           |                                 */
/*                               |    data _null_;                                      |                                 */
/*                               |      file "%sysfunc(getoption(WORK))/tmp.txt";       |                                 */
/*                               |      put "*";                                        |                                 */
/*                               |    run;quit;                                         |                                 */
/*                               |    ');                                               |                                 */
/*                               |   infile  "%sysfunc(getoption(WORK))/tmp.txt";       |                                 */
/*                               |   input @;                                           |                                 */
/*                               |   _infile_ = &str;                                   |                                 */
/*                               | %mend loadinfile;                                    |                                 */
/*                               |                                                      |                                 */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  str="Jhon Austin B 100kg";
    output;
  str="Mick Gray C 110kg";
     output;
  str="Tom Jef A30kg";
    output;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*                                                                                                                        */
/*         INPUT                                                                                                          */
/*         =====                                                                                                          */
/*                                                                                                                        */
/*  SD1.HAVE                                                                                                              */
/*                                                                                                                        */
/*          STR                                                                                                           */
/*                                                                                                                        */
/*  Jhon Austin B 100kg                                                                                                   */
/*  Mick Gray C 110kg                                                                                                     */
/*  Tom Jef A30kg                                                                                                         */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                       _       _       _
/ |  ___  __ _ ___    __| | __ _| |_ ___| |_ ___ _ __
| | / __|/ _` / __|  / _` |/ _` | __/ __| __/ _ \ `_ \
| | \__ \ (_| \__ \ | (_| | (_| | |_\__ \ ||  __/ |_) |
|_| |___/\__,_|___/  \__,_|\__,_|\__|___/\__\___| .__/
                                                |_|
*/

proc datasets lib=work nolist nodetails;
 delete want;
run;quit;

data want; ;

  set sd1.have;

  informat first last $8.
          therest $24. grade $1.;

  * load _infile_ buffer with variable str;
  %loadinfile(str);

  input first last therest & @;

  grade=compress(therest);
  weight=substr(compress(therest),2);

  * restart the buffer;
  input @1 @@;

  keep first last grade weight;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* WANT.SAS7BDAT                                                                                                          */
/*                                                                                                                        */
/*                                                                                                                        */
/* FIRST LAST   GRADE  WEIGHT                                                                                             */
/*                                                                                                                        */
/* Jhon  Austin   B     100kg                                                                                             */
/* Mick  Gray     C     110kg                                                                                             */
/* Tom   Jef      A      30kg                                                                                             */
/*                                                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                    _                 _   _        __ _ _
|___ \   ___  __ _ ___  | | ___   __ _  __| | (_)_ __  / _(_) | ___  _ __ ___   __ _  ___ _ __ ___
  __) | / __|/ _` / __| | |/ _ \ / _` |/ _` | | | `_ \| |_| | |/ _ \| `_ ` _ \ / _` |/ __| `__/ _ \
 / __/  \__ \ (_| \__ \ | | (_) | (_| | (_| | | | | | |  _| | |  __/| | | | | | (_| | (__| | | (_) |
|_____| |___/\__,_|___/ |_|\___/ \__,_|\__,_| |_|_| |_|_| |_|_|\___||_| |_| |_|\__,_|\___|_|  \___/

*/

%macro loadinfile(str)
  /des="load string into the infile buffer";
 %dosubl('
   data _null_;
     file "%sysfunc(getoption(WORK))/tmp.txt";
     put "*";
   run;quit;
   ');
  infile  "%sysfunc(getoption(WORK))/tmp.txt";
  input @;
  _infile_ = &str;

%mend loadinfile;
/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
