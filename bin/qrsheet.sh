#!/bin/sh
TMP=`mktemp -d`
bgpcoind dumpwallet $TMP/keys
c=0
cat > $TMP/walletsheet.html <<EOF
<head>
</head>
<body style="background-image:url(internet.png)">
<table>
<tr><th>Address</th><th>Amount</th><th>Private Key</th></tr>
EOF
for addr in $(bgpcoind listunspent | grep address | cut -f4 -d\" | sort | uniq)
do
	qrencode -o $TMP/a${c}.png $addr
	key=$(grep $addr $TMP/keys | awk '{print $1}')
	numbers=$(bgpcoind listunspent 6 9999999 [\"$addr\"] | grep amount | cut -f2 -d: | sed -s 's/,/+/' )
	amount=$(echo ${numbers}-0 | bc)
	qrencode -o $TMP/k${c}.png $key

cat >> $TMP/walletsheet.html <<EOF
<tr><td><img src="a${c}.png"></td><td>$amount</td><td><img src="k${c}.png"></td></tr>
<tr><td><h6>$addr</h6></td><td><h1>BGP</h1></td><td><h6>$key</h6></td></tr>
EOF

	c=$((c+1))
done

cat >> $TMP/walletsheet.html <<EOF
</table>
</body>
EOF

rsync --progress -aH internet.png $TMP/
rm -f $TMP/keys

rsync -aH $TMP/. $HOME/.bgpcoin/paperwallet && rm -rf $TMP && echo "Generated $c wallets"
