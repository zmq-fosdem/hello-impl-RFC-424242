#include <czmq.h>
#include <stdlib.h>

#define request "Hello"
#define reply "Noone home, go away!!!"

int main (int argc, char** argv)
{
    char buff[128];
    if(argc != 2) {
        printf("Usage server ip\n");
        exit(1);
    }
    int port = 16000 + (random() % 1000);
    sprintf(buff, "tcp://*:%d", port);
    zsock_t *rep = zsock_new_router (buff);
    sprintf(buff, "%s:%d", argv[1], port);
    zsock_t *pub = zsock_new_pub ("tcp://*:6665");
    printf("Listening on 'tcp://*:%d'\n", port);
    time_t last = 0;

    while(!zsys_interrupted) {
        if(time(NULL) - last > 1) {
            last = time(NULL);
            printf("Publishing '%s'\n", buff);
            zstr_send (pub, buff);
        }

        zsock_set_rcvtimeo (rep, 2000);
        zmsg_t* msg = zmsg_recv (rep);
        if(msg == NULL)
            continue;
        zframe_t* rt = zmsg_pop(msg);
        char* string = zmsg_popstr(msg);
        if(string != NULL && strncmp(string,request,strlen(request))==0) {
            zmsg_pushstr(msg,reply);
            zmsg_push(msg,rt);
            zmsg_send (&msg, rep);
            printf("Somebody pinged me\n");
        }
        zstr_free (&string);
    }

    zsock_destroy (&rep);
    zsock_destroy (&pub);
    return 0;
}
