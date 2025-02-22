# utl-expanding-sas-string-functionality-by-loading-strings-into-the-infile-buffer
This post loads a string variable into the infile buffer allowing access using the powerful sas input statement to parse the buffer
    %let pgm=utl-expanding-sas-string-functionality-by-loading-strings-into-the-infile-buffer;

    %stop_submission;

    This post loads a string variable into the infile buffer allowing access using the powerful sas input statement to parse the buffer.

    PROBLEM

    Input string operations to parse messy four word  string into name grade and weight

      CONTENTS

        1 sas load infile macro
        2 sas datastep solution

        3 Barts improved loadinfileB macro
          Bartosz Jablonski
          yabwon@gmail.com
          https://github.com/yabwon
        4 improved loadinfile macro example

    original infile trick;
    https://tinyurl.com/yjzm497y
    https://communities.sas.com/t5/SAS-Programming/How-to-delimit-large-dataset-28-Million-rows-into-700-variables/m-p/487676

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
    /*         INPUT                 |  PROCESSES                                           |     OUTPUT                      */
    /*         =====                 |  =========                                           |     ======                      */
    /*                               |                                                      |                                 */
    /*                               | 1 SAS LOAD INFILE MACRO                              |                                 */
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
    /* -----------------------------------------------------------------------------------------------------------------------*/
    /*                               |                                                      |                                 */
    /*  SD1.HAVE                     | 2 SAS DATASTEP SOLUTION                              |                                 */
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
    /*------------------------------------------------------------------------------------------------------------------------*/
    /*                               |                                                      |                                 */
    /*                               | 3 BARTS IMPROVED LOADINFILEB MACRO                   |                                 */
    /*                               | ==================================                   |                                 */
    /*                               |                                                      |                                 */
    /*                               | %macro loadinfileB(str,lrecl=32767)                  |                                 */
    /*                               |   /des="load string into the infile buffer";         |                                 */
    /*                               |  %local rc ff filrf fid;                             |                                 */
    /*                               |  %let ff = %sysfunc(datetime());                     |                                 */
    /*                               |  %let rc=%sysfunc(filename(filrf                     |                                 */
    /*                               |    ,%sysfunc(pathname(WORK))/empty&ff..txt));        |                                 */
    /*                               |  %let fid=%sysfunc(fopen(&filrf., a));               |                                 */
    /*                               |  %if &fid. > 0 %then                                 |                                 */
    /*                               |    %do;                                              |                                 */
    /*                               |       %let rc=%sysfunc(fwrite(&fid));                |                                 */
    /*                               |       %let rc=%sysfunc(fclose(&fid));                |                                 */
    /*                               |       infile                                         |                                 */
    /*                               |         "%sysfunc(pathname(WORK))/empty&ff..txt"     |                                 */
    /*                               |          lrecl=&lrecl.;                              |                                 */
    /*                               |       input @; _infile_ = &str;                      |                                 */
    /*                               |    %end;                                             |                                 */
    /*                               |  %else                                               |                                 */
    /*                               |     %do;                                             |                                 */
    /*                               |       putLOG "ERROR:&sysmacroname. Something";       |                                 */
    /*                               |       putlog "went wrong with the temp file...";     |                                 */
    /*                               |       stop;                                          |                                 */
    /*                               |     %end;                                            |                                 */
    /*                               | %mend loadinfileB;                                   |                                 */
    /*                               |                                                      |                                 */
    /*-------------------------------|------------------------------------------------------|---------------------------------*/
    /*                               |                                                      |                                 */
    /* DIFFERENT DATA EXAMPLE        | 4 IMPROVED LOADINFILE EXAMPLE DIFFERENT INPUT        |                                 */
    /*                               |==============================================        |                                 */
    /*                               |                                                      |                                 */
    /*          STR                  | data want(drop=str);                                 |  FIRST LAST   AGE  TEST         */
    /*                               |   set have;                                          |                                 */
    /*  John Carry   66              |   informat first last $8. age 2.;                    |  John  Carry   66  Bart         */
    /*  Andy NYC     32              |                                                      |  Andy  NYC     32  Bart         */
    /*                               |   * load _infile_ buffer with variable str;          |                                 */
    /*                               |   %loadinfileB(str, lrecl=128);                      |                                 */
    /*                               |                                                      |                                 */
    /*  DATA  have;                  |   input first last age & @;                          |                                 */
    /*    input str $64.;            |                                                      |                                 */
    /*  cards4;                      |   test = "Bart";                                     |                                 */
    /*  John Carry   66              |   * restart the buffer;                              |                                 */
    /*  Andy NYC     32              |   input @1 @@;                                       |                                 */
    /*  ;;;;                         | run;quit;                                            |                                 */
    /*  run;quit;                    |                                                      |                                 */
    /*                               |                                                      |                                 */
    /**************************************************************************************************************************/


    /*                  _                 _   _        __ _ _
    / | ___  __ _ ___  | | ___   __ _  __| | (_)_ __  / _(_) | ___  _ __ ___   __ _  ___ _ __ ___
    | |/ __|/ _` / __| | |/ _ \ / _` |/ _` | | | `_ \| |_| | |/ _ \| `_ ` _ \ / _` |/ __| `__/ _ \
    | |\__ \ (_| \__ \ | | (_) | (_| | (_| | | | | | |  _| | |  __/| | | | | | (_| | (__| | | (_) |
    |_||___/\__,_|___/ |_|\___/ \__,_|\__,_| |_|_| |_|_| |_|_|\___||_| |_| |_|\__,_|\___|_|  \___/

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

    /*___                        _       _            _                        _       _   _
    |___ \   ___  __ _ ___    __| | __ _| |_ __ _ ___| |_ ___ _ __   ___  ___ | |_   _| |_(_) ___  _ __
      __) | / __|/ _` / __|  / _` |/ _` | __/ _` / __| __/ _ \ `_ \ / __|/ _ \| | | | | __| |/ _ \| `_ \
     / __/  \__ \ (_| \__ \ | (_| | (_| | || (_| \__ \ ||  __/ |_) |\__ \ (_) | | |_| | |_| | (_) | | | |
    |_____| |___/\__,_|___/  \__,_|\__,_|\__\__,_|___/\__\___| .__/ |___/\___/|_|\__,_|\__|_|\___/|_| |_|
                         _                                   |_|
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
    /*  SD1.HAVE                                                                                                              */
    /*          STR                                                                                                           */
    /*  Jhon Austin B 100kg                                                                                                   */
    /*  Mick Gray C 110kg                                                                                                     */
    /*  Tom Jef A30kg                                                                                                         */
    /**************************************************************************************************************************/
    /*
     _ __  _ __ ___   ___ ___  ___ ___
    | `_ \| `__/ _ \ / __/ _ \/ __/ __|
    | |_) | | | (_) | (_|  __/\__ \__ \
    | .__/|_|  \___/ \___\___||___/___/
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
    /*  FIRST    LAST      GRADE    WEIGHT                                                                                    */
    /*                                                                                                                        */
    /*  Jhon     Austin      B      100kg                                                                                     */
    /*  Mick     Gray        C      110kg                                                                                     */
    /*  Tom      Jef         A      30kg                                                                                      */
    /**************************************************************************************************************************/

    /*____   _                _         _                                        _  _                 _ _        __ _ _      ____
    |___ /  | |__   __ _ _ __| |_ ___  (_)_ __ ___  _ __  _ __ _____   _____  __| || | ___   __ _  __| (_)_ __  / _(_) | ___| __ )
      |_ \  | `_ \ / _` | `__| __/ __| | | `_ ` _ \| `_ \| `__/ _ \ \ / / _ \/ _` || |/ _ \ / _` |/ _` | | `_ \| |_| | |/ _ \  _ \
     ___) | | |_) | (_| | |  | |_\__ \ | | | | | | | |_) | | | (_) \ V /  __/ (_| || | (_) | (_| | (_| | | | | |  _| | |  __/ |_) |
    |____/  |_.__/ \__,_|_|   \__|___/ |_|_| |_| |_| .__/|_|  \___/ \_/ \___|\__,_||_|\___/ \__,_|\__,_|_|_| |_|_| |_|_|\___|____/
                                                   |_|
    */

    filename ft15f001 "c:/oto/loadinfileb.sas";
    parmcards4;
    %macro loadinfileB(str,lrecl=32767)
      /des="load string into the infile buffer";
     %local rc ff filrf fid;
     %let ff = %sysfunc(datetime());
     %let rc=%sysfunc(filename(filrf
       ,%sysfunc(pathname(WORK))/empty&ff..txt));
     %let fid=%sysfunc(fopen(&filrf., a));
     %if &fid. > 0 %then
       %do;
          %let rc=%sysfunc(fwrite(&fid));
          %let rc=%sysfunc(fclose(&fid));
          infile
            "%sysfunc(pathname(WORK))/empty&ff..txt"
             lrecl=&lrecl.;
          input @; _infile_ = &str;
       %end;
     %else
        %do;
          putLOG "ERROR:&sysmacroname. Something";
          putlog "went wrong with the temp file...";
          stop;
        %end;
    %mend loadinfileB;
    ;;;;
    run;quit;

    /*  _     _                                        _  _                 _ _        __ _ _                                      _
    | || |   (_)_ __ ___  _ __  _ __ _____   _____  __| || | ___   __ _  __| (_)_ __  / _(_) | ___   _____  ____ _ _ __ ___  _ __ | | __
    | || |_  | | `_ ` _ \| `_ \| `__/ _ \ \ / / _ \/ _` || |/ _ \ / _` |/ _` | | `_ \| |_| | |/ _ \ / _ \ \/ / _` | `_ ` _ \| `_ \| |/ _
    |__   _| | | | | | | | |_) | | | (_) \ V /  __/ (_| || | (_) | (_| | (_| | | | | |  _| | |  __/|  __/>  < (_| | | | | | | |_) | |  _
       |_|   |_|_| |_| |_| .__/|_|  \___/ \_/ \___|\__,_||_|\___/ \__,_|\__,_|_|_| |_|_| |_|_|\___| \___/_/\_\__,_|_| |_| |_| .__/|_|\__
                         |_|                                                                                                |_|
    */

    data want(drop=str);
      set have;
      informat first last $8. age 2.;

      * load _infile_ buffer with variable str;
      %loadinfileB(str, lrecl=128);

      input first last age & @;

      test = "Bart";
      * restart the buffer;
      input @1 @@;
    run;quit;

    /**************************************************************************************************************************/
    /*  FIRST    LAST     AGE    TEST                                                                                         */
    /*                                                                                                                        */
    /*  John     Carry     66    Bart                                                                                         */
    /*  Andy     NYC       32    Bart                                                                                         */
    /**************************************************************************************************************************/

    /*              _
      ___ _ __   __| |
     / _ \ `_ \ / _` |
    |  __/ | | | (_| |
     \___|_| |_|\__,_|

    */
