#include <assert.h>
#include <czmq.h>

int main(int argc, char **argv) {
    assert (argv[1]);
    assert (argv[2]);

    zsock_t *client = zsock_new (ZMQ_REQ);
    assert (client);
    int rv = zsock_connect (client, argv[1]);
    assert (rv == 0);

    zstr_send (client, argv[2]);
    char *string = zstr_recv (client);
    printf ("Got: '%s'\n", string);

    zstr_free(&string);
    zsock_destroy (&client);
    return 0;
}
