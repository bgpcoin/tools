#!/bin/sh
TMP=`mktemp -d`
bgpcoind dumpwallet $TMP/keys
c=0
cat > $TMP/walletsheet.html <<EOF
<head>
</head>
<body>
<table>
<tr><th>Address</th><th>Private Key</th><th>Amount</th></tr>
EOF
for addr in $(bgpcoind listunspent | grep address | cut -f4 -d\" | sort | uniq)
do
	qrencode -o $TMP/a${c}.png $addr
	key=$(grep $addr $TMP/keys)
	amount=$(bgpcoind listunspent 6 9999999 [\"$addr\"] | grep amount | cut -f2 -d: | cut -f1 -d,)
	qrencode -o $TMP/k${c}.png $key

cat >> $TMP/walletsheet.html <<EOF
<tr><td><img src="a${c}.png"></td><td><img src="k${c}.png"></td><td>$amount</td></tr>
EOF

	c=$((c+1))
done

cat >> $TMP/walletsheet.html <<EOF
</table>
</body>
EOF

rm -f $TMP/keys

rsync -aH $TMP/. $HOME/.bgpcoin/paperwallet && rm -rf $TMP && echo "Generated $c wallets"
