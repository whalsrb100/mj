/*
runtime remove list code delete : line 313 ~
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define true 1
#define false 0
#define HYPHEN 0x2D
#define EOT 0x04
#define LF 0x0A
#define CR 0x0D

struct cont {
		struct cont *next, *prev;
		char *name, *ver, *arch;
};

/*
 =================================================

 GLOBAL ARGUMENTS
*/
int
	n_arg = 0,
	n_DataNum0 = 0,
	n_DataNum1 = 0,
	i = 0,
	j = 0;

struct cont
	*head0 = NULL,
	*head1 = NULL,
	*tail0 = NULL,
	*tail1 = NULL,
	*li=NULL,
	*dli=NULL;

char
	*sz_arg[2] = {NULL,},
	*sz_Filename1 = NULL,
	*sz_Filename2 = NULL,
	szbuf[2][128],
       	buf = 0;

FILE
	*p_fp = NULL;


/*
 =================================================
*/

void create_list()
{
	head0 = (struct cont*)malloc(sizeof(struct cont));
	tail0 = head0;
	tail0->prev = NULL;
	tail0->next = head0;
	n_DataNum0 = 0;
	tail0->name = NULL;
	tail0->ver  = NULL;
	tail0->arch = NULL;

	head1 = (struct cont*)malloc(sizeof(struct cont));
	tail1 = head1;
	tail1->prev = NULL;
	tail1->next = head1;
	n_DataNum1 = 0;
	tail1->name = NULL;
	tail1->ver  = NULL;
	tail1->arch = NULL;
}

void insert_node(int n)
{
	struct cont *new = (struct cont*)malloc(sizeof(struct cont));
	new->name = NULL;
	new->ver  = NULL;
	new->arch = NULL;
	new->next = NULL;

	switch(n)
	{
	case 0:{
		new->prev = tail0;
		tail0->next = new;
		tail0 = new;
		++n_DataNum0;
	       }break;
	case 1:{
		new->prev = tail1;
		tail1->next = new;
		tail1 = new;
		++n_DataNum1;
	       }break;
	}
}

void remove_list( struct cont *li )
{
	if(li->name != NULL) { free(li->name); li->name = NULL;}
	if(li->ver  != NULL) { free(li->ver ); li->ver  = NULL;}
	if(li->arch != NULL) { free(li->arch); li->arch = NULL;}

	if ( li != NULL )
	{
		if ( li == tail0 )
		{
			if( li->prev != head0 ) tail0 = li->prev;
			tail0->next = NULL;
			free(li);
			li=NULL;
		}
		else if ( li == tail1 )
		{
			if( li->prev != head1 ) tail1 = li->prev;
			tail1 = li->prev;
			tail1->next = NULL;
			free(li);
			li=NULL;
		}
		else if ( li == head0 )
		{
			free(head0);
		}
		else if ( li == head1 )
		{
			free(head1);
		}
		else
		{
			li->next->prev = li->prev;
			li->prev->next = li->next;
			free(li);
			li=NULL;
		}
	}
}

int CharType( char sz )
{
	if ( sz >= '0' && sz <= '9' ) { return 1; }
	else if (( sz >= 'a' && sz <= 'z' ) || ( sz >= 'A' && sz <= 'Z' ) || ( sz  == '.' || sz == '_' || sz == '@' )) { return 2; }
	else if ( sz == HYPHEN ) { return 4; }
	else if ( sz == LF || sz == CR ) { return 8; }
	else if ( sz == EOT || sz == EOF ) { return 16; }
	
	return false;
}

int ReadLine( FILE *fp, int *idx )
{
	int val = CharType( buf );
	if ( val == 2 ) { // char
		szbuf[0][(*idx)++] = buf;
		fread( &buf, sizeof(char), 1, fp );
		while( CharType( buf ) < 4)
		{
			szbuf[0][(*idx)++] = buf;
			fread( &buf, sizeof(char), 1, fp );
		}
	}
	else if ( val == 1 ) { // num
		szbuf[1][(*idx)++] = buf;
		fread( &buf, sizeof(char), 1, fp );
		while( CharType( buf ) < 4)
		{
			szbuf[1][(*idx)++] = buf;
			fread( &buf, sizeof(char), 1, fp );
		}
	}
	return CharType( buf );
}

void help(char *execute_file)
{
	printf("\tUsage : %s [file1] [file2]\n\n",execute_file);
	printf("\tSeparator Description:\n");
	printf("\t\t\"=\" : same package, same version.\n");
	printf("\t\t\"|\" : same package, different version.\n");
	printf("\t\t\"<\" : exist file1 only.\n");
	printf("\t\t\">\" : exist file2 only.\n\n");
	printf("\t[NOTE] The format of the contents of [file1] and [file2] must be\n\t\"<Package Name>-<Version>.<Archtecture>\"\n");
	printf("\n\tex) rpm -qa --queryformat \"%{NAME}-%{VERSION}.%{ARCH}\\n\"\n\n");
}

int init( int n_arg, char *sz_arg[] )
{
	if( n_arg < 3 || n_arg > 3 )
	{
		printf("\n\tThe usage is incorrect...\n");
		help(sz_arg[0]);
		return 1;
	}
	//File open;
	int idx[2]={0,},ret=0,i=0,j=0;
	for( i = 0 ; i < 2 ; ++i )
	{
		memset( szbuf[i], '\0', sizeof(char) * 127 );
	}
	create_list(n_arg);
	for( i = 0 ; i < 2 ; ++i )
	{
		p_fp = fopen( sz_arg[i+1], "r" );
		if ( !p_fp )
		{
			printf( "Can't not open file \"%s\"\n", sz_arg[i+1] );
			help(sz_arg[0]);
			return 1;
		}
		else
		{
			while( true )
			{
				fread( &buf, sizeof(char), 1, p_fp );
				if( CharType( buf ) == 2 ) // char
				{
					if ( idx[0] > 0 )
					{
						szbuf[0][idx[0]++] = '-';
					}
					ret = ReadLine( p_fp, &idx[0] );
				}
				else if( CharType( buf ) == 1 ) // num
				{
					if ( idx[1] > 0 )
					{
						szbuf[1][idx[1]++] = '-';
					}
					ret = ReadLine( p_fp, &idx[1] );
				}
				else
				{
					fread( &buf, sizeof(char), 1, p_fp );
					if ( CharType( buf ) >= 8 ) {
					ret = 0;
					memset( idx, 0, sizeof(int) * 2);
					for( j = 0 ; j < 2 ; ++j ) { memset( szbuf[j], 0, sizeof(char) * strlen( szbuf[j] ) ); }
						break;
					}
					else
					{
						fseek( p_fp, -2, SEEK_CUR );
						fread( &buf, sizeof(char), 1, p_fp );
					}
				}
				if ( ret >= 8 )
				{
					insert_node(i);
					int n_lang[2] = {0,}, n_arch_len=0;
					n_lang[0] = strlen( szbuf[0] );
					n_lang[1] = strlen( szbuf[1] );
	
					
					if ( szbuf[1][n_lang[1] - 6] == 'x' || szbuf[1][n_lang[1] - 6] == 'n' ) { n_arch_len=6; }
					else if ( szbuf[1][n_lang[1] - 4] == 'i' ) { n_arch_len=4; }
		
					switch(i)
					{
					case 0: {
					tail0->name = (char*)malloc(sizeof(char) * n_lang[0] + 1 );
					memcpy( tail0->name, szbuf[0], sizeof(char) * n_lang[0] );
					tail0->name[n_lang[0]] = '\0';
					tail0->arch = (char*)malloc(sizeof(char) * (n_arch_len + 1));
					memcpy( tail0->arch , &szbuf[1][n_lang[1]-n_arch_len], sizeof(char) * n_arch_len );
					tail0->arch[n_arch_len] = '\0';
					tail0->ver  = (char*)malloc(sizeof(char) * (( n_lang[1] - n_arch_len) ));
					memcpy( tail0->ver , szbuf[1], sizeof(char) * ( n_lang[1] - n_arch_len -1 ) );
					tail0->ver[n_lang[1] - n_arch_len - 1] = '\0';
						}break;
					case 1: {
					tail1->name = (char*)malloc(sizeof(char) * n_lang[0] + 1 );
					memcpy( tail1->name, szbuf[0], sizeof(char) * n_lang[0] );
					tail1->name[n_lang[0]] = '\0';
					tail1->arch = (char*)malloc(sizeof(char) * (n_arch_len + 1));
					memcpy( tail1->arch , &szbuf[1][n_lang[1]-n_arch_len], sizeof(char) * n_arch_len );
					tail1->arch[n_arch_len] = '\0';
					tail1->ver  = (char*)malloc(sizeof(char) * (( n_lang[1] - n_arch_len) ));
					memcpy( tail1->ver , szbuf[1], sizeof(char) * ( n_lang[1] - n_arch_len -1 ) );
					tail1->ver[n_lang[1] - n_arch_len - 1] = '\0';
						}break;
					}
					ret = 0;
					memset( idx, 0, sizeof(int) * 2);
					for( j = 0 ; j < 2 ; ++j ) { memset( szbuf[j], 0, sizeof(char) * strlen( szbuf[j] ) ); }
				}
			}//while
			fclose(p_fp);
			p_fp = NULL;
		}//else
	}//for
	return 0;
}

void diff_print()
{
	struct cont * tmp = NULL;
	for( li = head0->next ; li != NULL ; li = li->next )
	{
		for( dli = head1->next ; dli != NULL ; dli = dli->next )
		{
			if ( strcmp(li->name, dli->name) == 0 )
			{
				if ( strcmp(li->arch, dli->arch) == 0 )
				{
					if( strcmp( li->ver, dli->ver ) == 0 )
					{
						printf("%s-%s.%s\t=\t%s-%s.%s\n",li->name,li->ver,li->arch,dli->name,dli->ver,dli->arch);
					}
					else
					{
						printf("%s-%s.%s\t|\t%s-%s.%s\n",li->name,li->ver,li->arch,dli->name,dli->ver,dli->arch);
					}/*
					tmp = li->prev;
					remove_list(li);
					li = tmp;
					tmp = dli->prev;
					remove_list(dli);
					dli = tmp;
					tmp = NULL;*/
					break;
				}
			}
		}
	}
	for( li = head0->next ; li != NULL ; li = li->next )
	{
		printf("%s-%s.%s\t<\n",li->name,li->ver,li->arch);
	}
	for( li = head1->next ; li != NULL ; li = li->next )
	{
		printf("\t>\t%s-%s.%s\n",li->name,li->ver,li->arch);
	}
}

void update()
{
	diff_print();
}

void cleanup()
{
	struct cont *tmp = NULL;
	for( li = head0 ; li != NULL ; )
	{
		tmp = li->next;
		remove_list(li);
		li = tmp;
	}
	for( li = head1 ; li != NULL ; )
	{
		tmp = li->next;
		remove_list(li);
		li = tmp;
	}
}

void main( int Argc, char* Argv[] )
{
	if( init( Argc, Argv ) != 0 ) return;
	update();
	cleanup();
}
