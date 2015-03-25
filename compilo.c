#include <stdio.h>
#include <unistd.h>
#include "lex.yy.h"
#include "symtab.h"
#include "instructionmanager/instructions.h"
#include "instructionmanager/label.h"

extern int line;
extern int yydebug;
extern struct symtab *symbol_table;
extern struct simple_table *tmp_table;
extern struct instr_manager *instr_manager;
void yyparse();

int yyerror (char *s) {
        fprintf (stderr, "line %d: %s\n", line, s);
        exit(-1);
}

void print_usage(char *s)
{
    printf("usage : %s \n", s);
    printf("\t -h \t\t print this help\n");
    printf("\t -d \t\t enable parser debug\n");
    printf("\t -s \t\t enable symtab debug\n");
    printf("\t -f <filename>\t filename to parse\n");
    printf("\t\t\t if -f is not specified, stdin is parsed\n");
    printf("\t -S <filename>\t filename to write assembly\n");
    printf("\t -c \t\t enable color\n");
}

int main(int argc, char **argv) {
    int dflag = 0;
    int sflag = 0;
    int colorflag = 0;
    char *filename_in = NULL;
    char *filemane_out_asm = NULL;
    FILE *fin = NULL;
    FILE *fout_asm = NULL;
    int c = 0;

    while((c = getopt(argc, argv, "hc::d::s::f:S:")) != -1)
    {
        switch(c)
        {
            case 'h':
                print_usage(argv[0]);
                return EXIT_SUCCESS;
                break;

            case 'd': // debug
                dflag = 1;
                break;

            case 's': // symbol debug
                sflag = 1;
                break;

            case 'c':
                colorflag = 1;
                break;

            case 'f': // stdin
                filename_in = optarg;
                break;

            case 'S': // asm stdout
                filemane_out_asm = optarg;
                break;

            case '?':
                return EXIT_FAILURE;
                break;

        }
    }

    if(dflag)
    {
        yydebug = 1;
    }

    if(filename_in != NULL)
    {
        fin = fopen(filename_in, "r");
        if(fin == NULL)
        {
            printf("[-] %s not found ...\n", filename_in);
            return EXIT_FAILURE;
        }
        printf("[+] Reading from file %s\n", filename_in);
        yyin = fin;
    }

    if(filemane_out_asm != NULL)
    {
        fout_asm = fopen(filemane_out_asm, "w+");
        if(fout_asm == NULL)
        {
            printf("[-] unable to create %s ...\n", filemane_out_asm);
            return EXIT_FAILURE;
        }
    }

    symbol_table = symtab_create(256);
    tmp_table = table_create(256);
    instr_manager_init();

	yyparse();

    if(sflag)
    {
        printf("[+] Number of line(s) = %d\n", line);
        symtab_printf(symbol_table);
    }

    printf("[+] %d instructions generated\n", instr_manager->count);
    if(fout_asm == NULL)
    {
        instr_manager_print_textual(colorflag);
    } else {
        printf("[+] Writing asm to %s\n", filemane_out_asm);
        instr_manager_print_textual_file(fout_asm, 0);
    }

	return EXIT_SUCCESS;
}
