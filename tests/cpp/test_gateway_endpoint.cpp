#include "../../overlays/legacy/GatewayEndpointParser.h"
#include <assert.h>
#include <string.h>

static void valid(const char* text, const char* ip, unsigned short port)
{
    PtRecovery::GatewayEndpoint endpoint;
    assert(PtRecovery::ParseGatewayEndpoint(text, &endpoint));
    assert(strcmp(endpoint.ipv4, ip) == 0);
    assert(endpoint.port == port);
}

int main()
{
    valid("127.0.0.1:80", "127.0.0.1", 80);
    valid("10.11.12.13: 5622", "10.11.12.13", 5622);
    valid("1.2.3.4:\t65535", "1.2.3.4", 65535);
    valid("0.0.0.0:1", "0.0.0.0", 1);

    const char* invalid[] = {
        "", "127.0.0.1", "127.0.0.1:", ":80", "127.0.0.1:0",
        "127.0.0.1:65536", "127.0.0.1:-1", "127.0.0.1:+1",
        "127.0.0.1:12garbage", "127.0.0.1:80 ",
        "127.0.0.1:80:2", "1.2.3:80", "1.2.3.4.5:80",
        "256.2.3.4:80", "1.2.3.999:80", "1..3.4:80",
        "1.2.3.4.:80", "001.2.3.4:80", "1.02.3.4:80",
        "1.2.3.4:999999999999999999999", "1.2.3.4 :80",
        "hostname:80", "1.2.3.4:  "
    };
    PtRecovery::GatewayEndpoint endpoint;
    for (unsigned int i = 0; i < sizeof(invalid)/sizeof(invalid[0]); ++i)
        assert(!PtRecovery::ParseGatewayEndpoint(invalid[i], &endpoint));
    assert(!PtRecovery::ParseGatewayEndpoint(NULL, &endpoint));
    assert(!PtRecovery::ParseGatewayEndpoint("127.0.0.1:80", NULL));
    return 0;
}
