#!/bin/sh
TMP=`mktemp -d`
bgpcoind dumpwallet $TMP/keys
c=0
cat > $TMP/walletsheet.html <<EOF
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body style="background-image:url(internet.jpg)">
EOF
for addr in $(bgpcoind listunspent 0 | grep address | cut -f4 -d\" | sort | uniq)
do
cat >> $TMP/walletsheet.html <<EOF
<table>
<tr><th>Address</th><th>Amount</th><th>Private Key</th></tr>
EOF
	qrencode -m 4 -o $TMP/a${c}.png $addr
	key=$(grep $addr $TMP/keys | awk '{print $1}')
	numbers=$(bgpcoind listunspent 6 9999999 [\"$addr\"] | grep amount | cut -f2 -d: | sed -s 's/,/+/' )
	amount=$(echo ${numbers}-0 | bc)
	qrencode -m 4 -o $TMP/k${c}.png $key

cat >> $TMP/walletsheet.html <<EOF
<tr><td><img src="a${c}.png"></td><td><img src="bgp480.png"></td><td><img src="k${c}.png"></td></tr>
<tr><td class="address">$addr</td><td>$amount</td><td class="key">$key</td></tr>
</table>
<hr />
EOF

	c=$((c+1))
done

cat >> $TMP/walletsheet.html <<EOF
</body>
</html>
EOF

rsync --progress -aH bgp480.png internet.jpg internet.png style.css $TMP/
rm -f $TMP/keys

rsync -aH $TMP/. $HOME/.bgpcoin/paperwallet && rm -rf $TMP && echo "Generated $c wallets"
