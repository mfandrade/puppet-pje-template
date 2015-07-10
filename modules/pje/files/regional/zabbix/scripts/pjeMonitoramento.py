#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
Created on 10/04/2014
Responsável por monitorar os serviços do PJe. Banco, Receita e OAB
Para executar é necessário passar dois parâmetros: a url e o serviço
Por Exemplo python Disponibilidade_v2 avaliacao.pje.csjt.jus.br receita
teste4
@author: U019799
'''

import requests
#import re
import sys
import logging
#@from BaseHTTPServer import BaseHTTPRequestHandler
from contextlib import closing
#import json


#INICIO DA CLASSE
class Monitorar:
    def __init__(self, url, grau, servico):
        logging.info("-------------------VERIFICAR-----------------------")
        logging.info("Criando de Monitorar o PJe")
        logging.info("Serviço: "+servico)
        self._proxies = proxies = {
          "http": "http://proxy.tst.jus.br:3128",
          "https": "http://proxy.tst.jus.br:3128",
        }
        self._url = "http://"+str(url)+"/"+grau+"/seam/resource/rest/monitoracao/"+str(servico) 
        self._headers={'User-agent' : 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36'}
        self._grau = grau;
        self._html = ''
        self._listJson = None
        self._listaObjetos = None
    
    def conectar(self):
        try:
            logging.info("URL: " + self._url)
            logging.info("Instancia: " + self._grau)
            with closing(requests.get(self._url,
                                      stream=True,
                                      verify=False,
                                      headers=self._headers,
                                      timeout=30
                                      ,proxies=self._proxies
                                      )) as r:
                
                self._status_code = r.status_code
                self._content_type = r.headers['content-type']
                logging.info("Code: "+str(self._status_code))
                
                if self._status_code == 200:
                    logging.info(self._content_type)
                    if self._content_type == 'application/json':
                        json_data = r.json()
                        #logging.info(json_data['statusMonitoracao']['items']['item'])
                        self._listJson = json_data['statusMonitoracao']['items']['item']
                        self.criarObjetoServico();
                        self.verificarServico();
                        
                        #self._html += r.content
                        #self.tratarURLRegex()
                    else:
                        logging.info("Content type não é JSON")
                else:
                    logging.warning("Não foi possivel obter o JSON do serviço.")
                    print TipoRetorno.FALHA
                        
                    
            
        except Exception as inst:
            # pass
            logging.warning("URL: " + str(self._url))
            logging.warning("Code: "+str(TipoRetorno.SUCESSO))
            logging.warning(str(inst))
            logging.warning("----------------------------------------------------------------")
            print TipoRetorno.FALHA
            
    '''        
    def tratarURLRegex(self):
        logging.info(self._html)
        searchObj = re.search( '(OK)', self._html, re.M|re.I)
        if searchObj:
           print TipoRetorno.SUCESSO #"searchObj.group() : ", searchObj.group()
        else:
           print TipoRetorno.FALHA
    '''
                   
    def criarObjetoServico(self):
        sizeList = len(self._listJson)
        obj = None
        self._listaObjetos = list()
        
        if type(self._listJson) is list:
            for i in range(0,sizeList):
                obj = StatusServico(self._listJson[i]['status'], self._listJson[i]['mensagem'], self._listJson[i]['nome'])
                self._listaObjetos.append(obj)
        else:
            obj = StatusServico(self._listJson['status'], self._listJson['mensagem'], self._listJson['nome'])
            self._listaObjetos.append(obj)
        
        
            
    def verificarServico(self):
        for i in self._listaObjetos:
            logging.info(i._str())
            if i._status == False:
                print TipoRetorno.FALHA
                
        print TipoRetorno.SUCESSO
        
               
# FINAL DA CLASSE

# CLASSE PARA REPRESENTAR O TIPO DE RETORNO
class TipoRetorno():
    FALHA = 0 # informa que não foi encontrado a versão na pagina, pode ser que a pagina que esta sendo apresentada seja (sistema em manutencao)
    SUCESSO = 1
    
class StatusServico():
    def __init__(self, status, mensagem, nome):
        self._status = status
        self._mensagem = mensagem
        self._nome = nome
        
    def _str(self):
        return 'Status: '+str(self._status)+ ' Mensagem: '+str(self._mensagem)+' Nome: '+str(self._nome)
    
    def verificarServico(self):
        if self._status:
           print TipoRetorno.SUCESSO #"searchObj.group() : ", searchObj.group()
        else:
           print TipoRetorno.FALHA
    

# EXECUTAR
if __name__ == '__main__':
    logging.basicConfig(format='%(levelname)s: %(asctime)s %(message)s', level=logging.INFO)
    #logging.basicConfig(format='%(levelname)s: %(asctime)s %(message)s', level=logging.CRITICAL)
    '''
    urls = [
            'qualidade.pje.csjt.jus.br',
            'fluxo.pje.csjt.jus.br',
            'avaliacao.pje.csjt.jus.br',
            'treinamento.pje.csjt.jus.br']
    servicos = ['oab','receita','banco']
    
    
    for u in urls:
        for s in servicos:
            regional = Monitorar(u, "primeirograu", s)
            regional.conectar()
    '''
    #EXECUTAR
    total = len(sys.argv)
    #cmdargs = str(sys.argv)
    if total == 4 :
        #while True:
        regional = Monitorar(str(sys.argv[1]), str(sys.argv[2]), str(sys.argv[3]))
        regional.conectar()
    else :
        print("******************************Faltando parametro******************************************")
        print("Os parametros para serem passados devem ser:")
        print("01- a url do host, por exemplo: avaliacao.pje.csjt.jus.br")
        print("02- a instância do tribunal: primeirograu ou segundograu")
        print("03- o serviço a ser consutlado, podendo ser: receita, oab, banco, por exemplo: receita")
        print("*******************************************************************************************")
        sys.exit()
     