/* This program runs a script as suid.
 * The executable name and arguments are fixed.
 * 1999, Don Mahurin
 *
 * Usage:
 * cc sperl_user.c -o sperl_`whoami`
 * chmod a+x,u+s sperl_`whoami`
 *
 */

#include <stdio.h> /* for printf */
#include <stdlib.h> /* for FILE */
#include <unistd.h> /* for getuid, exec */
#include <sys/stat.h>

#define SCRIPTER "/usr/local/bin/perl5"
#define SCRIPTER_ARGS "-T-"
void exec_script( char *script_name, int argc, char *argv[])
{
   int i, myargc = 0;
   char **myargv = (char **)malloc(sizeof(char *) * (argc + 1));
   myargv[myargc++] = SCRIPTER;
   myargv[myargc++] = SCRIPTER_ARGS;
   for(i = 0; argc--;i++) {myargv[myargc++] = argv[i];  }
   myargv[myargc] = NULL;
   execv(SCRIPTER, myargv);
}

#define TRUSTED_ARGS "-T"

int main(int argc, char *argv[] )
{
   char *script_name;
   struct stat exe_stat;
   struct stat script_stat;
   int uid;
   int euid;
   FILE *scriptfile;
   char scriptline[256];
   char *exe_name;
   int linelen;

   if(argc < 2 )
   {
      fprintf(stderr, "This is only to be ran in a script\n");
      return(-1);
   }
/*   else if(argc > 2)
   {
      fprintf(stderr, "No arguments are allowed\n");
      return(-1);
   }
*/
   exe_name = argv[0];
   script_name = argv[1];

   if(stat(exe_name, &exe_stat) < 0)
   {
      fprintf(stderr, "stat failed on exe: %s\n", exe_name);
      return(-1);
   }
   euid = geteuid();
/*   printf("%s: e = %d . u = %d\n", argv[0], euid,exe_stat.st_uid); */
   if (euid != exe_stat.st_uid)
   {
      if (! (exe_stat.st_mode & S_ISUID))
      {
         printf("executable is not suid\n");
         return(-1);
      }
      /* executable is suid, but user did not change.  Try again. */
/*     printf("running again\n");*/
      execv(exe_name, argv);
   }
   argc--; argv++;

   scriptfile = fopen(script_name, "r");
   if(!scriptfile)
   {
      fprintf(stderr, "script not found: %s\n", script_name);
      return(-1);
   }
   fgets(scriptline, 256, scriptfile);
   fclose(scriptfile);
   if(scriptline[0] != '#' || scriptline[1] != '!')
   {
      fprintf(stderr, "not valid script\n");
      return(-1);
   }
   linelen = strlen(scriptline);
   while(scriptline[linelen -1] == '\n' || scriptline[linelen -1] == ' ')
   {
      scriptline[--linelen] = '\0';
   }
   if(strcmp(scriptline + 2, exe_name))
   {
      fprintf(stderr, "script executable is not this executable: %s, %s\n", scriptline + 2, exe_name);
      return(-1);
   }

   if(stat(script_name, &script_stat) < 0)
   {
      fprintf(stderr, "stat failed on script: %s\n", script_name);
      return(-1);
   }
   if (script_stat.st_mode & S_IWOTH || script_stat.st_mode & S_IWGRP)
   {
      printf("script is writable by someone other than user. I refuse to run it.\n");
      return(-1);
   }

   if ( script_stat.st_uid != euid)
   {
      printf("script_owner is not the same as executable owner: %s, %s\n", script_name, exe_name);
      return(-1);
   }
   else
   {
      exec_script(script_name, argc, argv);
   }
}
