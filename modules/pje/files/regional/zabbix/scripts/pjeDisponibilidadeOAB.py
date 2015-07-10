#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
Created on 05/05/2014

@author: U019799
'''
import suds
import logging
import sys
import os
import urllib2

class DisponibilidadeServico:
    def __init__(self):
        ConfigurarAmbiente()
        #self._url = 'http://www5.oab.org.br/cnaws/service.asmx?WSDL'
        self._url = 'http://www5.oab.org.br/ConsultaNacionalWS/ConsultaNacionalWs.asmx?WSDL'
        self._CPF = '47468769672'
        self._count_tentativa = 0

    def conectar(self):
        try:
            self._count_tentativa +=1
            logging.info(self._url)
            logging.info("Tentativa: " +str(self._count_tentativa))
            logging.debug("CPF: "+str(self._CPF))
            
            # FAZ A REQUISICAO PARA O WEBSEVICE
            client = suds.client.Client(self._url)

            #returnSoap = client.service.ConsultaAdvogadoPorCpf(self._CPF)
            returnSoap = client.service.RetornarDadosAdvogadoByCPF(self._CPF)
            #print returnSoap
            nome = returnSoap
            logging.info("Nome da pessoa pesquisada: "+str(nome))
            if nome != None:
                print TipoRetorno.SUCESSO
            else:
                print TipoRetorno.FALHA

        except Exception as inst:
            #pass
            logging.warning("Problema ao tentar consutlar o webservice"+ str(inst.args))
            if self._count_tentativa == 3:
                logging.warning("O numero de tentativas foi atingido: "+str(self._count_tentativa))
                print TipoRetorno.FALHA
                pass
            else:
                logging.info("Nova tentativa")
                self.conectar()
            raise  #re-raise the exact same exception that was thrown
            
#CLASSE PARA REPRESENTAR O TIPO DE RETORNO
class TipoRetorno():
    SUCESSO = 1
    FALHA = 0
    
class ConfigurarAmbiente():
    def __init__(self):
        logging.info("Configurando o ambiente")
        os.environ['http_proxy']="http://proxy.tst.jus.br:3128"
        os.environ['https_proxy']="http://proxy.tst.jus.br:3128"
        logging.info("HTTP PROXY: "+os.environ['http_proxy'])
        logging.info("HTTPS PROXY: "+os.environ['https_proxy'])
    


if __name__ == '__main__':
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.CRITICAL)
    #logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)
    #logging.basicConfig(filename='log.log', filemode='w', level=logging.DEBUG)
    logging.info(__name__)
    url = None   
            
    #EXECUTAR
    total = len(sys.argv)
    if total == 2:
        url = sys.argv[1]
        logging.info("Url: "+str(url))
        pje = DisponibilidadeServico(url)
    else:
        pje = DisponibilidadeServico()      
    
    pje.conectar()
