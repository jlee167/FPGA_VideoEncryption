/*
 * main.c
 *
 *  Created on: Apr 18, 2016
 *      Author: jlee167
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define to_hw_port (volatile char*) 0x10003080 // actual address here
#define to_hw_sig (volatile char*) 0x10003070 // actual address here
#define to_sw_port (char*) 0x10003060 // actual address here
#define to_sw_sig (char*) 0x10003050 // actual address here

int main()
{

	int pixel[640][480];

	int i;
	unsigned char row_key[9];
	unsigned char column_key[11];
	unsigned char diaognal_key[4];
	unsigned char SEED[4];
	char Command;
	char garbage;

	*to_hw_sig = 0;
	*to_hw_port = 0;

	while(1)
	{
		*to_hw_sig = 0;
		*to_hw_port = 0;

		printf("\n Enter Key 1 (8 characters prompt) : \n");
		scanf("%08s",row_key);
		printf("\n%s : \n", row_key);

		printf("\n Enter Key 2 (10 characters prompt) : \n");
		scanf("%10s", column_key);
		printf("\n%s : \n", column_key);

		printf("\n Enter Key3: (3 characters prompt)\n");
		scanf("%3s", diaognal_key);
		printf("\n%s : \n", diaognal_key);

		printf("\n Enter Seed: (3 characters prompt)");
		scanf("%3s", SEED);
		printf("\n%s : \n", SEED);

		scanf("%c", &garbage);
		printf("\n Command: ");
		scanf("%c", &Command);
		printf("\n%c : \n", Command);

		if ( (Command == 'E') || (Command == 'D') )
		{
			while (*to_sw_sig != 1)
				*to_hw_sig = 1;

			for (i = 0; i < 8; i++)
			{
				*to_hw_port = row_key[i];
				*to_hw_sig = 2;
				if (*to_sw_sig == 2)
					*to_hw_sig = 3;
				while (*to_sw_sig != 3) {};
			}

			while (*to_sw_sig != 4)
				*to_hw_sig = 4;

			for (i = 0; i < 10; i ++)
			{
				*to_hw_port = column_key[i];
				*to_hw_sig = 5;
				if (*to_sw_sig == 5)
					*to_hw_sig = 6;
				while (*to_sw_sig != 6);
			}

			while (*to_sw_sig != 7)
				*to_hw_sig = 7;

			for (i = 0; i < 3; i ++)
			{
				*to_hw_port = diaognal_key[i];
				*to_hw_sig = 8;
				if (*to_sw_sig == 8)
					*to_hw_sig = 9;
				while (*to_sw_sig != 9);
			}
			if ( Command == 'E')
				*to_hw_port = 1;
			else if ( Command == 'D')
				*to_hw_port = 0;

			*to_hw_sig = 10;
			while (*to_sw_sig != 10) {};

			*to_hw_sig = 0;
		}
	}
	return 0;
}
