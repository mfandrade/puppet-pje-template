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
          "http": "http://u019799:123456789@proxy3.tst.jus.br:3128",
          "https": "http://u019799:123456789@proxy3.tst.jus.br:3128",
        }
        self._url = url
        self._grau = grau
        #self._headers = {'User-agent' : 'Mozilla/5.0'}
        self._headers={'User-agent' : 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36'}
        self._html = ''
        self._status_code = None
        self._opcao = None
    
    def conectar(self):
        try:
            if self._opcao == None:
                self._url = "http://" + str(self._url) + "/" + str(self._grau) + "/login.seam"
            else:
                self._url = "http://" + str(self._url) + "/" + str(self._grau) +"-"+str(self._opcao)+ "/login.seam"
                logging.info("Opcao: " + self._opcao)
            
            logging.info("URL: " + self._url)
            logging.info("Instancia: " + self._grau)
            with closing(requests.get(self._url,
                                      stream=True,
                                      verify=False,
                                      headers=self._headers,
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
    if total == 3 or total == 4 :
        nomeRegional = str(sys.argv[1])
        instancia = str(sys.argv[2])
        nomeArquivoLog = "/usr/lib/zabbix/externalscripts/log/"+nomeRegional+"_"+ instancia + '_log.log'
        regional = DisponibilidadeRegional(nomeRegional, instancia)
        if total == 4:
            regional._opcao = str(sys.argv[3])
        
        regional.conectar()
        
    else :
        logging.info("******************************Faltando parametro******************************************")
        logging.info("Os parametros a serem passados devem ser:")
        logging.info("01- a url do host, por exemplo: avaliacao.pje.csjt.jus.br")
        logging.info("02- o grau a ser consultado, exemplo: primeirograu")
        logging.info("*******************************************************************************************")
        sys.exit()
'''
    urls = [
            #'10.0.17.6:8080',            
            #'10.0.17.8:8080',
            'ena.pje.csjt.jus.br']
    
    
    for i in range(100):
        for s in urls:
            regional = DisponibilidadeRegional(s, "segundograu")
            regional.conectar()
'''