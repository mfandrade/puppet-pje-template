#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
Created on 02/05/2014

@author: U019799
'''

import urllib2
import urllib
import cookielib
import re

#INICIO DA CLASSE
class DisponibilidadeBNDT:
    
    def __init__(self, proxy):
        self._proxies = {"http":proxy }
        self._url = "http://homologacao.jt.jus.br/cndt/login?metodo=logoff" 
        self._headers={'User-agent' : 'Mozilla/5.0'}
        self._username='usuario@trt5.jus.br'
        self._password='cndt2011'
        self._html = ''
    
    def conectar(self):
        try:
            # Store the cookies and create an opener that will hold them
            cj = cookielib.CookieJar()
            opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
            # Install our opener (note that this changes the global opener to the one
            # we just made, but you can also just call opener.open() if you want)
            urllib2.install_opener(opener)
            # Input parameters we are going to send
            payload = {  
              'usuario': self._username,
              'senha': self._password
              }
            # Use urllib to encode the payload
            data = urllib.urlencode(payload)
            # Build our Request object (supplying 'data' makes it a POST)
            req = urllib2.Request(self._url, data, self._headers)
            # Make the request and read the response
            resp = urllib2.urlopen(req)
            self._html = resp.read()
        except Exception :
            #raise  #re-raise the exact same exception that was thrown
            #print("problema")
            pass
        
    def tratarURLRegex(self):
        searchObj = re.search( 'XML para CNDT', self._html, re.M|re.I)
        #searchObj = re.search( 'Credenciamento de Advogados', self._html, re.M|re.I)
        if searchObj:
           print 1 #"searchObj.group() : ", searchObj.group()
        else:
           print 0 #"Nothing found!!"
        
    def toString(self):
        print(self._html)
#FINAL DA CLASSE
#executar
bndt = DisponibilidadeBNDT("proxy.tst.jus.br:3128")
bndt.conectar()
#bndt.toString()
bndt.tratarURLRegex()