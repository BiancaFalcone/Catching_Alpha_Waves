#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

#define MAILBOX_BASE 0x40000000
#define MAILBOX_OFFSET (0x00007000U)
#define MAILBOX_LEN 0x1000U
#define DIMMAX 12000
#define DIMMIN 200

void campionalo(int*);
void alzalo(unsigned int*);
void stampavalori(float*,int*,int*);


// intero che descrive il file
int fd = -1;
// copia dell'indirizzo della mailbox
unsigned int *memmap = NULL;

/* inizializza la mailbox, aprendo il file /dev/mem
 * e mappando il suo contenuto in memoria
 */
unsigned int* init_mailbox()
{
	unsigned int *result;
	fd = open("/dev/mem", O_RDWR | O_SYNC);
	if (fd < 0) {
		printf("cannot open /dev/mem\n");
		exit(-1);
	}
	result = (unsigned int*)mmap(NULL, MAILBOX_LEN, PROT_READ
			| PROT_WRITE, MAP_SHARED, fd, MAILBOX_BASE + MAILBOX_OFFSET);
	if (result == MAP_FAILED) {
		printf("cannot mmap /dev/mem\n");
		exit(-1);
	}
	memmap = result;
	return result;
}

// chiude la mailbox chiudendo il file fd
void close_mailbox()
{
	munmap(memmap, MAILBOX_LEN);
	close(fd);
}

int main()
{
	unsigned int *mailbox;
	unsigned int value;
	int i=0;
	int dati[12000], sum=0, campioni;
	float media;

	mailbox = init_mailbox();
	printf("mailbox initialized\n");

	mailbox[0] = 0;
	mailbox[1] = 0;
 	mailbox[2] = 0;
	mailbox[3] = 0;
	mailbox[4] = 0;

		campionalo(&campioni);

		alzalo(mailbox);

	mailbox[0] = 1;
	do {
		if (mailbox[2] == 1){
			dati[i] = mailbox[1];
			sum=sum+dati[i];
			i++;
			mailbox[2] = 0;
		}
	} while (i!= campioni);
	mailbox[4]=4;
	media=sum/campioni;
	stampavalori(&media,dati,&campioni);
	//fclose (f);

    return 0;
}

void campionalo(int *campioni){
	int tempo, fc=200;
	do{
		printf("Per quanto tempo vuoi campionare il segnale (consentito valore intero compreso tra 10s e 60s)?");
		scanf("%d",&tempo);
		*campioni=tempo*fc;

	} while ((*campioni<DIMMIN) || (*campioni>DIMMAX));
}

void alzalo (unsigned int mailbox[]){
	do{
		printf("Alza TUTTI gli SWITCH per attivare campionamento!!!\n ");
		usleep(3000000);
	}while (mailbox[3] != 15);
}

void stampavalori(float *media,int dati[DIMMAX],int *campioni){
	int i;
	FILE *f = fopen("Dati.txt", "w");
	for (i=0; i<*campioni;i++)
		fprintf(f,"%f\n",dati[i]-(*media));
	fclose (f);

}

