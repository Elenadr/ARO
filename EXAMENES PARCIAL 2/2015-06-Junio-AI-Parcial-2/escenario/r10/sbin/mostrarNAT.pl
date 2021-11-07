#! /usr/bin/perl -w


# print header
print"IP prv : Pto prv\tIP pub : Pto pub\tIP rem : Pto rem\tProt\n";
print"-------------------------------------------------------------------------------\n";



############################################################
#### parsing manually opened ports from iptables
############################################################

system ('iptables -t nat -L -n | grep DNAT > /tmp/open-ports.tmp');
open(MANUALS, '/tmp/open-ports.tmp');

while (<MANUALS>) {
	chomp;
	$linea = $_;
	@tokens = split(/\s+/, $linea);

	$prot = $tokens[1];
	$ip_pub = $tokens[4];

	foreach $token (@tokens) {
		if ($token =~ m/dpt:/) {
			($trash, $pto_pub) = split(/:/, $token);
		}
		if ($token =~ m/to:/) {
			($trash, $ip_prv, $pto_prv) = split(/:/, $token);
		}
	}
	
	$extra_tab_1 =  (length("$ip_prv : $pto_prv") < 16) ? "\t" : "";
	$extra_tab_2 =  (length("$ip_pub : $pto_pub") < 16) ? "\t" : "";
	print "$ip_prv : $pto_prv\t$extra_tab_1$ip_pub : $pto_pub\t$extra_tab_2* : *\t\t\t$prot (m)\n";
}
close(MANUALS);
system ('rm -f /tmp/open-ports.tmp');


############################################################
#### parsing active connections from /proc/net/ip_conntrack
############################################################

#system ('cat /proc/net/ip_conntrack | grep ESTABLISHED > /tmp/open-conns.tmp');
system ('cat /proc/net/ip_conntrack > /tmp/open-conns.tmp');
open(CONNS, '/tmp/open-conns.tmp');

while (<CONNS>) {
	chomp;
	$linea = $_;
	($linea_snd, $linea_rsp) = split(/bytes/, $linea);
	@tokens_snd = split(/\s+/, $linea_snd);
	@tokens_rsp = split(/\s+/, $linea_rsp);

	$prot = $tokens_snd[0];

	foreach $token (@tokens_snd) {
		if ($token =~ m/src=/) {
			($trash, $ip_prv) = split(/=/, $token);
		}
		if ($token =~ m/sport=/) {
			($trash, $pto_prv) = split(/=/, $token);
		}
		if ($token =~ m/dst=/) {
			($trash, $ip_rem) = split(/=/, $token);
		}
		if ($token =~ m/dport=/) {
			($trash, $pto_rem) = split(/=/, $token);
		}
	}

	foreach $token (@tokens_rsp) {
		if ($token =~ m/dst=/) {
			($trash, $ip_pub) = split(/=/, $token);
		}
		if ($token =~ m/dport=/) {
			($trash, $pto_pub) = split(/=/, $token);
		}
	}

	if ($ip_prv ne $ip_pub) {
	  $extra_tab_1 =  (length("$ip_prv : $pto_prv") < 16) ? "\t" : "";
	  $extra_tab_2 =  (length("$ip_pub : $pto_pub") < 16) ? "\t" : "";
	  $extra_tab_3 =  (length("$ip_rem : $pto_rem") < 16) ? "\t" : "";
	  print "$ip_prv : $pto_prv\t$extra_tab_1$ip_pub : $pto_pub\t$extra_tab_2$ip_rem : $pto_rem\t$extra_tab_3$prot (a)\n";
	}
}
close(CONNS);
system ('rm -f /tmp/open-conns.tmp');

