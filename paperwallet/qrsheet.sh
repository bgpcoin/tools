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
<body style="background-image:url(internet.png)">
<table>
<tr><th>Index</th><th>Address</th><th>Amount</th><th>Private Key</th></tr>
EOF
for addr in $(bgpcoind listunspent | grep address | cut -f4 -d\" | sort | uniq)
do
	qrencode -o $TMP/a${c}.png $addr
	key=$(grep $addr $TMP/keys | awk '{print $1}')
	numbers=$(bgpcoind listunspent 6 9999999 [\"$addr\"] | grep amount | cut -f2 -d: | sed -s 's/,/+/' )
	amount=$(echo ${numbers}-0 | bc)
	qrencode -o $TMP/k${c}.png $key

cat >> $TMP/walletsheet.html <<EOF
<tr><td></td><td><img src="a${c}.png"></td><td><strong>$amount</strong><img src="bgp480.png"></td><td><img src="k${c}.png"></td></tr>
<tr><td>$c</td><td class="address">$addr</td><td><img src="bgp480.png"></td><td class="key">$key</td></tr>
EOF

	c=$((c+1))
done

cat >> $TMP/walletsheet.html <<EOF
</table>
</body>
</html>
EOF

rsync --progress -aH bgp480.png internet.png style.css $TMP/
rm -f $TMP/keys

rsync -aH $TMP/. $HOME/.bgpcoin/paperwallet && rm -rf $TMP && echo "Generated $c wallets"
