#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/sendfile.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

#define FILEBUF 4096

typedef struct {
    int fd;
    size_t size;
} file_t;

int fd_copy(int from, int to, off_t count) {
    char *buf=malloc(FILEBUF);//Buffer to read from file
    int reads,wrote;
    int retval=0;

    //Sends file
    while (count>0 && (reads=read(from, buf, FILEBUF<count? FILEBUF:count ))>0) {
        count-=reads;
        wrote=write(to,buf,reads);
        if (wrote!=reads) { //Error writing to the descriptor
            retval=1;
            break;
        }
    }

    free(buf);
    return retval;
}

int acceptsocket(int port) {

    int sockfd, newsockfd;
    socklen_t clilen;
    struct sockaddr_in serv_addr, cli_addr;

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    bzero((char *) &serv_addr, sizeof(serv_addr));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(port);
    {
        int val=1;
        setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(val));
    }
    if (bind(sockfd, (struct sockaddr *) &serv_addr,
             sizeof(serv_addr)) < 0)
        error("ERROR on binding");
    listen(sockfd,5);
    clilen = sizeof(cli_addr);
    newsockfd = accept(sockfd,NULL,NULL);
    if (newsockfd < 0)
        error("ERROR on accept");
    return newsockfd;
}

file_t openfile(char *fname) {
    file_t r;
    struct stat buf;

    r.fd=open(fname,O_RDONLY);

    fstat(r.fd,&buf);

    r.size=buf.st_size;
    return r;
}

int main () {

    file_t locfile=openfile("/tmp/test.dat");
    int sock=acceptsocket(12345);

    printf("file fd: %d\nsocket fd: %d\n",locfile.fd,sock);
    //sendfile(sock, locfile.fd, NULL,locfile.size);
    fd_copy(locfile.fd,sock,locfile.size);
    return 0;
}
