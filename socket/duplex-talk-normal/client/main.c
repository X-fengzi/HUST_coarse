// added by wliu, for windows socket programming
#include <windows.h>
#include <winsock2.h>

#include <stdio.h>
#include <string.h>
#include <conio.h>fgets(buf, sizeof(buf), stdi
#define SERVER_PORT 5432
#define MAX_LINE 256


int main(int argc, char * argv[])
{
    // added by wliu, for windows socket programming
    WSADATA WSAData;
    int WSAreturn;

    //FILE *fp;
    SYSTEMTIME sys;
    struct hostent *hp;
    struct sockaddr_in sin;
    char *host;
    char buf[MAX_LINE],buf1[MAX_LINE];
    int s;
    int len;

    if (argc==2) {
		host = argv[1];
    }
    else {
		fprintf(stderr, "usage: duplex-talk host\n");
		exit(1);
    }

    // added by wliu, for windows socket programming
	WSAreturn = WSAStartup(0x101,&WSAData);
	if(WSAreturn)
	{
	    fprintf(stderr, "duplex-talk: WSA error.\n");
		exit(1);
	}

    /* translate host name into peer's IP address */
    hp = gethostbyname(host);
    if (!hp) {
		fprintf(stderr, "duplex-talk: unknown host: %s\n", host);
		exit(1);
    }

    /* build address data structure */
    // modified by wliu, for string memory operation
    //bzero((char *)&sin, sizeof(sin));
    //bcopy(hp->h_addr, (char *)&sin.sin_addr, hp->h_length);
    memset((char *)&sin, 0, sizeof(sin));
    memcpy((char *)&sin.sin_addr, hp->h_addr, hp->h_length);

    sin.sin_family = AF_INET;
    sin.sin_port = htons(SERVER_PORT);

    /* active open */
    if ((s = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
		perror("duplex-talk: socket failed.");
		exit(1);
    }
    if (connect(s, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
		perror("duplex-talk: connect failed.");
		close(s);
		exit(1);
    }

    fprintf(stderr, "client is connecting to %s\n", host);
    int Timeout=100;
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO,(char *)&Timeout, sizeof(int));
    /* main loop: get and send lines of text */
    while(1)
    {


    if (kbhit()) {
        GetLocalTime(&sys);
        printf("%02d:%02d:%02d [duplex-talk] client: ", sys.wHour, sys.wMinute, sys.wSecond);
        fgets(buf, sizeof(buf), stdin);
		buf[MAX_LINE-1] = '\0';
		len = strlen(buf) + 1;
		send(s, buf, len, 0);
		if(!strcmp(buf,"\n"))
        {
             GetLocalTime(&sys);
             printf("%02d:%02d:%02d [duplex-talk]: ", sys.wHour, sys.wMinute, sys.wSecond);
             printf("empty message is sent to server\n");
             break;
        }
    }

    if (len = recv(s, buf1, sizeof(buf1), 0)>0)  {
            //printf("received %2d chars:", len);
            GetLocalTime(&sys);
            printf("%02d:%02d:%02d [duplex-talk] server: ", sys.wHour, sys.wMinute, sys.wSecond);
            fputs(buf1, stdout);
            if (strcmp(buf1,"ACK!\n"))
            {
                 GetLocalTime(&sys);
                printf("%02d:%02d:%02d [duplex-talk] client: ACK!\n", sys.wHour, sys.wMinute, sys.wSecond);
                send(s,"ACK!\n\0",6,0);
            }
            buf1[0]='\0';
        }

    }
    GetLocalTime(&sys);
    printf("%02d:%02d:%02d [duplex-talk]: ", sys.wHour, sys.wMinute, sys.wSecond);
    printf("connection is terminated\n");

    // added by wliu, for windows socket programming
    WSACleanup();
    return 1;
}

