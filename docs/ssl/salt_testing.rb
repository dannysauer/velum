#!/usr/bin/env ruby
################################################################################
# Generate the Velumdex/k8sapi certs for testing
#
################################################################################

require './gen_certs'

ca = RootCA.new(1024)
ica = IntermediateCA.new(ca, 1024)

# velum
# todo: generate expired and valid certs

altname_list = [
  # velum
  [ "DNS:admin",
    "DNS:admin.infra.caasp.local",
    "DNS:b34af80fcc9e4a59ad14c1c2e1f54313",
    "DNS:b34af80fcc9e4a59ad14c1c2e1f54313.infra.caasp.local",
    "DNS:admin.devenv.caasp.suse.net",
    "IP Address:10.17.1.0"
  ],
  # dex
  [ "DNS:master-2",
    "DNS:master-2.infra.caasp.local",
    "DNS:61a89c5405fa405e8fb6a2904c139824",
    "DNS:61a89c5405fa405e8fb6a2904c139824.infra.caasp.local",
    "DNS:kubernetes",
    "DNS:kubernetes.default",
    "DNS:kubernetes.default.svc",
    "DNS:api",
    "DNS:api.infra.caasp.local",
    "DNS:kube-api-x3.devenv.caasp.suse.net",
    "IP Address:172.24.0.1",
    "DNS:dex",
    "DNS:dex.kube-system",
    "DNS:dex.kube-system.svc",
    "DNS:dex.kube-system.svc.infra.caasp.local",
    "DNS:kubernetes.default.svc.cluster.local"
  ],
  # kube API
  [ "DNS:admin",
    "DNS:admin.infra.caasp.local",
    #"DNS:b34af80fcc9e4a59ad14c1c2e1f54313",
    #"DNS:b34af80fcc9e4a59ad14c1c2e1f54313.infra.caasp.local",
    "DNS:master-0",
    "DNS:master-0.infra.caasp.local",
    #"DNS:f46276632b5543d998914a9504d72596",
    #"DNS:f46276632b5543d998914a9504d72596.infra.caasp.local",
    "DNS:master-1",
    "DNS:master-1.infra.caasp.local",
    "DNS:master-2",
    "DNS:master-2.infra.caasp.local",
    "DNS:kubernetes",
    "DNS:kubernetes.default",
    "DNS:kubernetes.default.svc",
    "DNS:api",
    "DNS:api.infra.caasp.local",
    "DNS:kube-api-x3.devenv.caasp.suse.net",
    "DNS:kubernetes.default.svc.cluster.local",
    "IP Address:172.24.0.1"
  ]
]

crt1 = ServerCert.new(
  ca
  [ "DNS:host1",
    "DNS:host2",
    "IP:1.2.3.4"
  ],
  start_time=Time.now,
  lifetime_secs=1*365*24*60*60
  )

#dex

puts crt1.pem
