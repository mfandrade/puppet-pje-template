#!/bin/bash

arquivo=$1

if [ -n "$arquivo" ]; then

	sed -i '/<stringProp name="Argument.name">javax.faces.ViewState<\/stringProp>/{n;s/.*/<stringProp name="Argument.value">${VIEWSTATE}<\/stringProp>\n/;}' $arquivo
	sed -i '/<stringProp name="Argument.name">javax.faces.FormSignature<\/stringProp>/{n;s/.*/<stringProp name="Argument.value">${FORMSIGNATURE}<\/stringProp>\n/;}' $arquivo
	sed -i '/<stringProp name="Argument.name">cid<\/stringProp>/{n;s/.*/<stringProp name="Argument.value">${CID}<\/stringProp>\n/;}' $arquivo
	sed -i '/<stringProp name="Argument.name">idProcesso<\/stringProp>/{n;s/.*/<stringProp name="Argument.value">${ID_PROCESSO}<\/stringProp>\n/;}' $arquivo
	sed -i '/cid=[0-9]*<\/stringProp>/s/cid=[0-9]*<\/stringProp>/cid=${CID}<\/stringProp>/g' $arquivo	
	sed -i '/idProcesso=[0-9]*<\/stringProp>/s/idProcesso=[0-9]*<\/stringProp>/idProcesso=${ID_PROCESSO}<\/stringProp>/g' $arquivo
	sed -i '/^$/d' $arquivo

else
	echo "[ERRO] - arquivo nao encontrado $arquivo"
fi