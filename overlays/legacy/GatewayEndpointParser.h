#ifndef PT_RECOVERY_GATEWAY_ENDPOINT_PARSER_H
#define PT_RECOVERY_GATEWAY_ENDPOINT_PARSER_H

// Portable C++98 validation for legacy gateway IPv4:port client-info strings.
// Include only in an external working copy; preserve the original PT.zip bytes.
#include <stddef.h>
#include <string.h>

namespace PtRecovery {

struct GatewayEndpoint {
    char ipv4[16];
    unsigned short port;
};

inline bool ParseGatewayEndpoint(const char* input, GatewayEndpoint* output)
{
    if (input == NULL || output == NULL)
        return false;

    const char* colon = strchr(input, ':');
    if (colon == NULL)
        return false;
    const size_t ip_length = (size_t)(colon - input);
    if (ip_length < 7 || ip_length >= sizeof(output->ipv4))
        return false;

    unsigned int octet = 0;
    unsigned int digits = 0;
    unsigned int dots = 0;
    bool leading_zero = false;
    for (const char* p = input; p != colon; ++p) {
        if (*p == '.') {
            if (digits == 0 || octet > 255 || dots >= 3)
                return false;
            ++dots;
            digits = 0;
            octet = 0;
            leading_zero = false;
        } else {
            if (*p < '0' || *p > '9' || digits >= 3 ||
                (digits > 0 && leading_zero))
                return false;
            if (digits == 0)
                leading_zero = (*p == '0');
            octet = octet * 10 + (unsigned int)(*p - '0');
            ++digits;
        }
    }
    if (dots != 3 || digits == 0 || octet > 255)
        return false;

    const char* port_text = colon + 1;
    // The historical gateway may include a blank after ':'.
    while (*port_text == ' ' || *port_text == '\t')
        ++port_text;
    if (*port_text < '0' || *port_text > '9')
        return false;

    unsigned long port = 0;
    do {
        port = port * 10 + (unsigned long)(*port_text - '0');
        if (port > 65535UL)
            return false;
        ++port_text;
    } while (*port_text >= '0' && *port_text <= '9');
    if (*port_text != '\0' || port == 0)
        return false;

    memcpy(output->ipv4, input, ip_length);
    output->ipv4[ip_length] = '\0';
    output->port = (unsigned short)port;
    return true;
}

}  // namespace PtRecovery
#endif  // PT_RECOVERY_GATEWAY_ENDPOINT_PARSER_H
