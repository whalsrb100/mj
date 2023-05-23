#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//#define __DEBUG

#define TRUE 0
#define FALSE 1
#define CHECK -1

enum e_CHAR { NAME = 0x00, VAL = 0x01 };


enum e_CharType {
	SPACE=0x10,
	DOT=0x20,
	EQUAL=0x30,
	NEWLINE=0x40,
	CHAR=0x50,
	TAB=0x60
};

struct strnode
{
	char *str;
	struct strnode *next, *prev;
	int wc;
};
struct node
{
	struct node *next, *prev;
	struct strnode *head[2], *tail[2];
};

/*=======================*/
struct node *head[2] = {NULL,}, *tail[2] = {NULL,}, *li = NULL;
struct strnode *str_li = NULL;
char buf = 0, tmp[128] = {0,};
int i = 0, j = 0, bufidx = 0, idx[16] = {0,}, idxcnt = 0;
enum e_CHAR echar = NAME;
FILE *fp[2]={NULL,};
/*=======================*/

int list_create()
{
	int i=0;
	for ( i = 0 ; i < 2 ; ++i )
	{
		head[i] = (struct node*)malloc(sizeof(struct node));
		head[i]->next = NULL;
		head[i]->prev = NULL;
		tail[i] = head[i];
	}
	return TRUE;
}

int list_add_node(int num)
{
	struct node *new = (struct node*)malloc(sizeof(struct node));
	tail[num]->next = new;
	new->prev = tail[num];
	new->next = NULL;
	tail[num] = new;
	return TRUE;
}

int list_insert_data(int num, enum e_CHAR echar)
{
	if( tail[num]->head[echar] == NULL )
	{
		tail[num]->head[echar] = (struct strnode*)malloc(sizeof(struct strnode));
		tail[num]->head[echar]->str = NULL;
		tail[num]->tail[echar] = tail[num]->head[echar];
	}
	else
	{
		struct strnode *strnew = NULL;
		strnew = (struct strnode*)malloc(sizeof(struct strnode));
		strnew->next = NULL;
		strnew->str = NULL;
		strnew->wc = 0;
		tail[num]->tail[echar]->next = strnew;
		strnew->prev = tail[num]->tail[echar];
		tail[num]->tail[echar] = strnew;
	}

	tail[num]->tail[echar]->str = (char*)malloc( bufidx + 1);
	memcpy( tail[num]->tail[echar]->str, tmp, bufidx );
	tail[num]->tail[echar]->str[bufidx] = '\0';
	memset ( tmp , 0 , sizeof(char) * 128 );
	bufidx=0;
	if(echar == NAME) { ++tail[num]->tail[echar]->wc; }
	return TRUE;
}

int list_remove_all()
{
	struct node *iter = NULL;
	struct strnode *str_iter = NULL;
	int i=0;
	for ( i = 0 ; i < 2 ; ++i )
	{
		iter = head[i];
		while ( iter != NULL )
		{
			str_iter = iter->head[i];
			while ( str_iter != NULL )
			{
				if ( str_iter->str != NULL  )
				{
					free(str_iter->str);
				}

				iter->head[i] = iter->head[i]->next;
				free ( str_iter );
				str_iter = iter->head[i];
			}
			head[i] = iter->next;
			if ( iter != NULL ) {free( iter ); }
			iter = head[i];
		}
	}
	return TRUE;
}

int help(char *thisfile)
{
	printf("Usage : %s <file1> <file2>\n",thisfile);
	printf("\"sysctl -a\"\n");

	return FALSE;
}

int CharType( char buf )
{
	if (	( buf >= 'a' && buf <= 'z' ) ||
		( buf >= 'A' && buf <= 'Z' ) ||
		( buf >= '0' && buf <= '9' ) ||
		buf == ',' || buf == '/' || buf == '!' || buf == '@' ||
		buf == '#' || buf == '$' || buf == '%' || buf == '^' ||
		buf == '&' || buf == '*' || buf == '(' || buf == ')' ||
		buf == '-' || buf == '_' || buf == '+' || buf == '[' || 
		buf == ']' || buf == ';' || buf == ':' || buf == '"' ||
		buf == '\''|| buf == '\\'|| buf == '?' || buf == '~' || buf == '`' 	
	   ) // char;
	{
		return CHAR;
	}
	else if ( ' ' == buf  )  { return SPACE;    }
	else if ( '\t' == buf ) { return TAB;    }
	else if ( '.' == buf  )  { return DOT;      }
	else if ( '=' == buf  )  { return EQUAL;    }
	else if ( '\n' == buf ) { return NEWLINE; }
	else if ( '\r' == buf ) { return NEWLINE; }
	else if ( 0x0A == buf ) { return NEWLINE; }
	else { return FALSE; }
}

int splitParam()
{
	return TRUE;
}

int openFile(char *FileName, int num, FILE *p_fp)
{
	if ( p_fp == NULL ) { p_fp = fopen( FileName, "r" ); }
	if ( !p_fp )
	{
		printf("not found %s\n",FileName);
		return FALSE;
	}
	else
	{
		static int IsEnd=0;
		static int IsStop=0;
		while( IsStop==0 )
		{
			fread( &buf, sizeof(char), 1, p_fp);
			switch( CharType( buf ) )
			{
				case CHAR:
				case SPACE:	{	// space
					IsEnd=0;
					tmp[bufidx++] = buf;
						}break;
				case TAB:	{	// tab
					IsEnd=0;
					tmp[bufidx++] = ' ';
						}break;
				case DOT:	{	// next array..
					if(echar == VAL)
					{
						tmp[bufidx++] = buf;
					}
					else if ( echar == NAME )
					{
						IsEnd=0;
						list_insert_data(num,echar);
					}
						}break;
				case EQUAL:	{	// value..
					IsEnd=0;
					list_insert_data(num,echar);
					echar = VAL;
						}break;
				case NEWLINE:	{	// next line or end file..
					if( IsEnd > 0 )
					{
						IsStop = 1;
						bufidx = 0;
						memset ( tmp , 0 , sizeof(char) * 128 );
						IsEnd = 0;
					}
					else
					{
						list_insert_data(num,echar);
						list_add_node(num);
						echar = NAME;
						++IsEnd;
						bufidx = 0;
						memset ( tmp , 0 , sizeof(char) * 128 );
					}
						}break;
			}
		}
		IsStop=0;
		// finished read;
	}
	return TRUE;

	// HOW TO USE : fseek();
	// ex) fseek( p_fp, -2, SEEK_CUR );
}

int Initialize(int argc, char *argv[])
{
	if( argc != 3 )
	{
		return help(argv[0]);
	}

	list_create();

	int i=0;
	for ( i = 0 ; i < 2 ; ++i )
	{
		if ( openFile( argv[i+1], i, fp[i] ) == FALSE )
		{
			if( fp[i] != NULL ) { fclose(fp[i]); }
		//	return FALSE;
		}
	}
	
	return TRUE;
}
void Update()
{
	static char separator = '=';
	static struct strnode *cmp0 = NULL, *cmp1 = NULL;
	static struct node *node0 = NULL, *node1 = NULL, *node_t = NULL;
	node0 = head[0];
	node1 = head[1];
	cmp0=node0->head[NAME];
	cmp1=node1->head[NAME];
	while( node0 != NULL && cmp0 != NULL && node1 != NULL && cmp1 != NULL )
	{
		if( cmp0->wc == cmp1->wc )
		{
			int IsSame = 1;
			int cnt = cmp0->wc;
			for ( cmp0 = node0->head[NAME], cmp1 = node1->head[NAME] ; cmp0 != NULL && cmp1 != NULL ; cmp0 = cmp0->next, cmp1 = cmp1->next )
			{
				if( strcmp(cmp0->str, cmp1->str) != 0 ) { IsSame = 0; break; } else { continue; }
			}

			if ( IsSame == 0 ) { // different
				cmp0=node0->head[NAME];
				node1 = node1->next;
				if( node1 == NULL )
				{
					node0 = node0->next;
					node1 = head[1];
					cmp1=node1->head[NAME];
					break;
				}
				cmp1=node1->head[NAME];
			}
			else
			{
				separator = '=';
				cmp0=node0->head[VAL];
				cmp1=node1->head[VAL];
				if( strcmp(cmp0->str, cmp1->str) != 0 ) { separator='|'; }

				cmp0=node0->head[NAME];
				for ( cmp0 = node0->head[NAME] ; cmp0 != NULL ; cmp0 = cmp0->next )
				{
					(cmp0->next == NULL) ? printf("%s=",cmp0->str) : printf("%s.",cmp0->str);
				}
				if ( node0->head[VAL]->str != NULL ) { printf("%s",node0->head[VAL]->str); }
				printf("\t%c\t",separator);

				cmp1=node1->head[NAME];
				for ( cmp1 = node1->head[NAME] ; cmp1 != NULL ; cmp1 = cmp1->next )
				{
					(cmp1->next == NULL) ? printf("%s=",cmp1->str) : printf("%s.",cmp1->str);
				}
				if ( node1->head[VAL]->str != NULL ) { printf("%s\r\n",node1->head[VAL]->str); }
				

				//remove node0
				if(node0 == head[0])
				{
					head[0] = head[0]->next;
					if( node0->head[NAME]->str != NULL ) { free( node0->head[NAME]->str ); }
					if( node0->head[VAL]->str != NULL ) { free( node0->head[VAL]->str ); }
					node0->head[NAME]->wc=0;
					node0->head[VAL]->wc=0;
					if( node0->head[NAME] != NULL ) { free( node0->head[NAME] ); }
					if( node0->head[VAL] != NULL ) { free( node0->head[VAL] ); }
					free(node0);
					node0 = head[0];
					cmp0 = node0->head[NAME];
				}
				else if(node0 == tail[0])
				{
					tail[0] = tail[0]->prev;
					if( node0->head[NAME]->str != NULL ) { free( node0->head[NAME]->str ); }
					if( node0->head[VAL]->str != NULL ) { free( node0->head[VAL]->str ); }
					node0->head[NAME]->wc=0;
					node0->head[VAL]->wc=0;
					if( node0->head[NAME] != NULL ) { free( node0->head[NAME] ); }
					if( node0->head[VAL] != NULL ) { free( node0->head[VAL] ); }
					free(node0);
					node0 = NULL;
					cmp0 = NULL;
					break;
				}
				else
				{
					node_t = node0->next;
					node0->prev->next = node0->next;
					node0->next->prev = node0->prev;
					if( node0->head[NAME]->str != NULL ) { free( node0->head[NAME]->str ); }
					if( node0->head[VAL]->str != NULL ) { free( node0->head[VAL]->str ); }
					node0->head[NAME]->wc=0;
					node0->head[VAL]->wc=0;
					if( node0->head[NAME] != NULL ) { free( node0->head[NAME] ); }
					if( node0->head[VAL] != NULL ) { free( node0->head[VAL] ); }
					free(node0);
					node0 = node_t;
					cmp0 = node0->head[NAME];
					node_t = NULL;
				}
				//remove node1
				if(node1 == head[1])
				{
					head[1] = head[1]->next;
					if( node1->head[NAME]->str != NULL ) { free( node1->head[NAME]->str ); }
					if( node1->head[VAL]->str != NULL ) { free( node1->head[VAL]->str ); }
					node1->head[NAME]->wc=0;
					node1->head[VAL]->wc=0;
					if( node1->head[NAME] != NULL ) { free( node1->head[NAME] ); }
					if( node1->head[VAL] != NULL ) { free( node1->head[VAL] ); }
					free(node1);
					node1 = head[1];
					cmp1 = node1->head[NAME];
				}
				else if(node1 == tail[1])
				{
					tail[1] = tail[1]->prev;
					if( node1->head[NAME]->str != NULL ) { free( node1->head[NAME]->str ); }
					if( node1->head[VAL]->str != NULL ) { free( node1->head[VAL]->str ); }
					node1->head[NAME]->wc=0;
					node1->head[VAL]->wc=0;
					if( node1->head[NAME] != NULL ) { free( node1->head[NAME] ); }
					if( node1->head[VAL] != NULL ) { free( node1->head[VAL] ); }
					free(node1);
					node1 = NULL;
					cmp1 = NULL;
					break;
				}
				else
				{
					node_t = node1->next;
					node1->prev->next = node1->next;
					node1->next->prev = node1->prev;
					if( node1->head[NAME]->str != NULL ) { free( node1->head[NAME]->str ); }
					if( node1->head[VAL]->str != NULL ) { free( node1->head[VAL]->str ); }
					node1->head[NAME]->wc=0;
					node1->head[VAL]->wc=0;
					if( node1->head[NAME] != NULL ) { free( node1->head[NAME] ); }
					if( node1->head[VAL] != NULL ) { free( node1->head[VAL] ); }
					free(node1);
					node1 = node_t;
					cmp1 = node1->head[NAME];
					node_t = NULL;
				}
			} // cmp == 0
		} // cmp
	} // node1 : while

        i=0;
	for ( i = 0 ; i < 2 ; ++i )
	{
		separator = (i == 0) ? '<' : '>' ;
		if ( i == 0 )
		{
			node0 = head[0];
			while( node0 != NULL )
			{
				for ( cmp0 = node0->head[NAME] ; cmp0 != NULL ; cmp0 = cmp0->next )
				{
					(cmp0->next == NULL) ? printf("%s=",cmp0->str) : printf("%s.",cmp0->str);
				}
				if ( node0->head[VAL] != NULL && node0->head[VAL]->str != NULL ) { printf("%s\t%c\n",node0->head[VAL]->str,separator); }
				node0 = node0->next;
			}
		}
		else if( i == 1 )
		{
			node1 = head[1];
			while( node1 != NULL )
			{
				if ( node1->head[VAL] != NULL && node1->head[VAL]->str != NULL ) { printf("\t%c\t",separator); }
				for ( cmp1 = node1->head[NAME] ; cmp1 != NULL ; cmp1 = cmp1->next )
				{
					(cmp1->next == NULL) ? printf("%s=",cmp1->str) : printf("%s.",cmp1->str);
				}
				if ( node1->head[VAL] != NULL && node1->head[VAL]->str != NULL ) { printf("%s\n",node1->head[VAL]->str); }
				node1 = node1->next;
			}
		}
	}
}
int Cleanup()
{
        i=0;
	for ( i = 0 ; i < 2 ; ++i )
	{
		if( fp[i] != NULL ) { fclose(fp[i]); }
	}
	list_remove_all();
	return TRUE;
}
	
int main( int argc, char *argv[] )
{
	if ( Initialize(argc, argv) == FALSE) { return Cleanup(); }
	Update();
	return Cleanup();
}
