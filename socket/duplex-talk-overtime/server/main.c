// added by wliu, for windows socket programming
#include <windows.h>
#include <winsock2.h>

#include <stdio.h>
#include <string.h>

#define SERVER_PORT 5432
#define MAX_PENDING 5
#define MAX_LINE 256


int main()
{
    // added by wliu, for windows socket programming
    WSADATA WSAData;
    int WSAreturn;

    /* server address */
    struct sockaddr_in sin;
    // client address, added by wliu, for comments
    struct sockaddr_in remote;

    char buf[MAX_LINE],buf1[MAX_LINE];
    int len;
    int s, new_s;
    int i=0;
    SYSTEMTIME sys;
    // added by wliu, for windows socket programming
	WSAreturn = WSAStartup(0x101,&WSAData);
	if(WSAreturn)
	{
	    fprintf(stderr, "duplex-talk: WSA error.\n");
		exit(1);
	}

    /* build address data structure */
    // added by wliu, for string memory operation
    //bzero((char *)&sin, sizeof(sin));
    memset((char *)&sin, 0, sizeof(sin));

    sin.sin_family = AF_INET;
    sin.sin_addr.s_addr = INADDR_ANY;
    sin.sin_port = htons(SERVER_PORT);

    /* setup passive open */
    if ((s = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
		perror("duplex-talk: socket failed.");
		exit(1);
    }
    if ((bind(s, (struct sockaddr *)&sin, sizeof(sin))) < 0) {
		perror("duplex-talk: bind failed.");
		exit(1);
    }

    // added by wliu, for comments
    printf("server is ready in listening ...\n");

    listen(s, MAX_PENDING);

    /* wait for connection, then receive and print text */
    while(1) {
        // added by wliu, correction
        len = sizeof(struct sockaddr_in);

        if ((new_s = accept(s, (struct sockaddr *)&remote, &len)) < 0){
            perror("duplex-talk: accept failed.");
            exit(1);
        }
        int Timeout=100;
        printf("received a connection from %s : \n", inet_ntoa(remote.sin_addr));
        setsockopt(new_s, SOL_SOCKET, SO_RCVTIMEO,(char *)&Timeout, sizeof(int));
        while(1){
            int Timeout=100;
            setsockopt(new_s, SOL_SOCKET, SO_RCVTIMEO,(char *)&Timeout, sizeof(int));
            if(len = recv(new_s, buf, sizeof(buf), 0)>0)
            {
                 if(!strcmp(buf,"\n"))
                 {
                    GetLocalTime(&sys);
                    printf("%02d:%02d:%02d [duplex-talk]: ", sys.wHour, sys.wMinute, sys.wSecond);
                    printf("empty message is received\n");
                    GetLocalTime(&sys);
                    printf("%02d:%02d:%02d [duplex-talk] server: ACK!\n", sys.wHour, sys.wMinute, sys.wSecond);
                    send(new_s,"ACK!\n\0",6,0);
                    goto end;
                 }
                i++;
                if(i==3)
                {
                     //printf("received %2d chars:", len);
                 GetLocalTime(&sys);
                 printf("%02d:%02d:%02d [duplex-talk] client: ", sys.wHour, sys.wMinute, sys.wSecond);
                 fputs(buf, stdout);
                 send(new_s,"ACK!\n\0",6,0);
                 GetLocalTime(&sys);
                 printf("%02d:%02d:%02d [duplex-talk] server:ACK!\n", sys.wHour, sys.wMinute, sys.wSecond);
                 i=0;
                }
                else{
                    continue;
                }

            }
            if(kbhit())
            {
                GetLocalTime(&sys);
                printf("%02d:%02d:%02d [duplex-talk] server: ", sys.wHour, sys.wMinute, sys.wSecond);
                fgets(buf1, sizeof(buf1), stdin);
                buf[MAX_LINE-1] = '\0';
                len = strlen(buf1) + 1;
                send(new_s, buf1, len, 0);
                 int Timeout=1000;
                setsockopt(new_s, SOL_SOCKET, SO_RCVTIMEO,(char *)&Timeout, sizeof(int));
                while(1)
                {
                    if (len = recv(new_s, buf, sizeof(buf1), 0)<0)  {
                    //printf("received %2d chars:", len);
                        GetLocalTime(&sys);
                        printf("%02d:%02d:%02d [duplex-talk] server(time out): %s", sys.wHour, sys.wMinute, sys.wSecond, buf1);
                        send(new_s, buf1, len, 0);
                        continue;

                    }
                    else
                    {
                        GetLocalTime(&sys);
                        printf("%02d:%02d:%02d [duplex-talk] client: ", sys.wHour, sys.wMinute, sys.wSecond);
                        fputs(buf, stdout);
                        if(!strcmp(buf,"ACK!\n"))
                        {
                            break;
                        }
                        else
                        {
                           GetLocalTime(&sys);
                            printf("%02d:%02d:%02d [duplex-talk] client(time out): %s", sys.wHour, sys.wMinute, sys.wSecond, buf);
                            send(new_s, buf1, len, 0);
                            continue;
                        }
                    }
                }

            }

        }
        end:
        GetLocalTime(&sys);
        printf("%02d:%02d:%02d [duplex-talk]: ", sys.wHour, sys.wMinute, sys.wSecond);
        printf("connection from %s is terminated\n",inet_ntoa(remote.sin_addr));

        close(new_s);
    }

    // added by wliu, for windows socket programming
    WSACleanup();
	return 1;
}
