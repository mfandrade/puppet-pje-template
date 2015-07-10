#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
Created on 14/04/2014

@author: U019799
'''
import requests
from contextlib import closing
import re
import logging
import sys
import os
from BaseHTTPServer import BaseHTTPRequestHandler

# INICIO DA CLASSE
class DisponibilidadeRegional:
    
    def __init__(self, url, grau):
        logging.info("-------------------VERIFICAR-----------------------")
        logging.info("Criando objeto Disponibilidade Regional: "+url)
        self._proxies = proxies = {
          "http": "http://proxy.tst.jus.br:3128",
          "https": "http://proxy.tst.jus.br:3128",
        }
        self._url = "http://" + str(url) + "/" + str(grau) + "/login.seam"
        self._grau = grau
        self._headers = {'User-agent' : 'Mozilla/5.0'}
        self._html = ''
        self._status_code = None
    
    def conectar(self):
        try:
            logging.info("URL: " + self._url)
            logging.info("Instancia: " + self._grau)
            with closing(requests.get(self._url,
                                      stream=True,
                                      verify=False,
                                      timeout=29
                                      #,proxies=self._proxies
                                      )) as r:
                
                self._status_code = r.status_code
                if self._status_code == 200:
                    self._html += r.content
                    self.tratarURLRegex()
                else:
                    logging.warning("URL: " + str(self._url))
                    logging.warning("Code: "+str(r.status_code))
                    logging.warning(BaseHTTPRequestHandler.responses.get(r.status_code))
                    logging.warning("----------------------------------------------------------------")
                    print self._status_code
            
        except Exception as inst:
            # pass
            logging.warning("URL: " + str(self._url))
            logging.warning("Code: "+str(TipoRetorno.TIME_OUT))
            logging.warning(str(inst))
            logging.warning("----------------------------------------------------------------")
            print TipoRetorno.TIME_OUT
        
    def tratarURLRegex(self):
        searchObj = re.search('[1][.]\d[.]\d[.]\d', self._html, re.M | re.I)
        logging.info("Verificar se a regional esta no AR pela procura da versão")
        
        if searchObj:
           print self._status_code  # "searchObj.group() : ", searchObj.group()
           logging.info("Sucesso. code:"+str(self._status_code))
        else:
           print TipoRetorno.FALHA  # "Nothing found!!"
           logging.info("Falha. code:"+str(self._status_code))
# FINAL DA CLASSE

# CLASSE PARA REPRESENTAR O TIPO DE RETORNO
class TipoRetorno():
    FALHA = 0 # informa que não foi encontrado a versão na pagina, pode ser que a pagina que esta sendo apresentada seja (sistema em manutencao)
    TIME_OUT = 50
    

# EXECUTAR
if __name__ == '__main__':
    logging.basicConfig(format='%(levelname)s: %(asctime)s %(message)s', level=logging.INFO)
    
    total = len(sys.argv)
    if total == 3 :
        # "u019799:123456789@proxy3.tst.jus.br:3128",
        nomeRegional = str(sys.argv[1])
        instancia = str(sys.argv[2])
        nomeArquivoLog = "/usr/lib/zabbix/externalscripts/log/"+nomeRegional+"_"+ instancia + '_log.log'
        #nomeArquivoLog = nomeRegional+"_"+ instancia + '_log.log'
        #logging.basicConfig(filename=nomeArquivoLog, format='%(levelname)s: %(asctime)s %(message)s', filemode='a+', level=logging.WARNING)
        regional = DisponibilidadeRegional(nomeRegional, instancia)
        regional.conectar()
        
    else :
        logging.info("******************************Faltando parametro******************************************")
        logging.info("Os parametros a serem passados devem ser:")
        logging.info("01- a url do host, por exemplo: avaliacao.pje.csjt.jus.br")
        logging.info("02- o grau a ser consultado, exemplo: primeirograu")
        logging.info("*******************************************************************************************")
        sys.exit()
    

    '''
    urls = ['pje.trt1.jus.br',
            'pje.trt2.jus.br',
            'pje.trt3.jus.br',
            'pje.trt4.jus.br',
            'pje.trt5.jus.br',
            'pje.trt6.jus.br',
            'pje.trt7.jus.br',
            'pje.trt8.jus.br',
            'pje.trt9.jus.br',
            'pje.trt10.jus.br',
            'pje.trt11.jus.br',
            'pje.trt12.jus.br',
            'pje.trt13.jus.br',
            'pje.trt14.jus.br',
            'pje.trt15.jus.br',
            'pje.trt16.jus.br',
            'pje.trt17.jus.br',
            'pje.trt18.jus.br',
            'pje.trt19.jus.br',
            'pje.trt20.jus.br',
            'pje.trt21.jus.br',
            'pje.trt22.jus.br',
            'pje.trt23.jus.br',
            'pje.trt24.jus.br']
    
    
    for s in urls:
        regional = DisponibilidadeRegional(s, "primeirograu")
        regional.conectar()
        #regional.tratarURLRegex()
    '''