from prometheus_client import start_http_server, Gauge

import netsnmp

# Create a metric to track time spent and requests made.
# REQUEST_TIME = Summary('request_processing_seconds', 'Time spent processing request')
core1_loading = Gauge('core1_loading', 'Core 1 loading')
core2_loading = Gauge('core2_loading', 'Core 2 loading')
core3_loading = Gauge('core3_loading', 'Core 3 loading')
core4_loading = Gauge('core4_loading', 'Core 4 loading')


core1_loading_oid = netsnmp.Varbind('HOST-RESOURCES-MIB::hrProcessorLoad.196608')
core2_loading_oid = netsnmp.Varbind('HOST-RESOURCES-MIB::hrProcessorLoad.196609')
core3_loading_oid = netsnmp.Varbind('HOST-RESOURCES-MIB::hrProcessorLoad.196610')
core4_loading_oid = netsnmp.Varbind('HOST-RESOURCES-MIB::hrProcessorLoad.196611')

serv = '127.0.0.1'
snmp_pass = 'public'

if __name__ == '__main__':
    # Start up the server to expose the metrics.
    start_http_server(8000)
    # Generate some requests.
    while True:
        core1 = netsnmp.snmpget(core1_loading_oid, Version=2, DestHost=serv, RemotePort='161', Community=snmp_pass)
        #print(type(core1[0]))
        #core1 = float(core1[0])
        core1_loading.set(core1[0])

        core2 = netsnmp.snmpget(core2_loading_oid, Version=2, DestHost=serv, RemotePort='161', Community=snmp_pass)
        core2 = float(core2[0])
        core2_loading.set(core2)

        core3 = netsnmp.snmpget(core3_loading_oid, Version=2, DestHost=serv, RemotePort='161', Community=snmp_pass)
        core3 = float(core3[0])
        core3_loading.set(core3)

        core4 = netsnmp.snmpget(core4_loading_oid, Version=2, DestHost=serv, RemotePort='161', Community=snmp_pass)
        core4 = float(core4[0])
        core4_loading.set(core4)
