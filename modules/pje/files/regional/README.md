## Regional

-------

-------

**Repositório contendo os arquivos de configuração mais atuais do Apache, Jboss e Postgres utilizados no PJE.**

Esse repositório tem como finalidade o suporte aos Tribunais Regionais, para a comparação e/ou download dos arquivos de configuração atualizados.

--------

--------

## Tutorial para baixar os arquivos do GitLab para sua máquina local.

---
Objetivo: fazer o download dos arquivos contidos no repositório GitLab do projeto regional.

---

___

## Para plataforma Windows
---

### Pré-requisitos

-Usuario cadastrado no GitLab (https://git.pje.csjt.jus.br/).

-Download da ferramenta "puttygen.exe" e "TortoiseGit-1.8.8.0-64bit.msi" (http://pje.csjt.jus.br/ferramentas/)

-Ferramenta "TortoiseGit" instalado.




### Adicionar Chave Pública ao GitLab

1 -  Faça o Download do arquivo "PuttyGen".

2 -  Abra o arquivo "PuttyGen".

3 -  Com o programa aberto, clique em "Generate".

4 -  Faça movimento com o mouse no espaço em baixo da barra de progresso até que ela se conclua.

5 -  No campo "Key comment" apague o que estiver escrito e coloque seu e-mail funcional (xxx@tst.jus.br).

6 -  Salve sua chave pública e privada clicando em "Save public key" e "Save private key".

7 -  Copie todo o texto contido no campo "Public key for pasting into OpenSSH authorized_keys file:".

8 -  Faça o Login no GitLab.

9 -  Clique em "Profile settings" (perto da imagem do seu profile).

10 - Vá na aba "SSH Keys".

11 - Clique em "Add SSH Key".

12 - Cole o texto copiado do  campo "Public key for pasting into OpenSSH authorized_keys file:" no espaço em branco "Key".
** Note que seu e-mail corporativo deve aparecer automaticamente no campo "Title", caso isso não aconteça clique em algum lugar fora do campo "key".
Observe se não há nenhum espaço ao final do seu e-mail corporativo. **

13 - Para finalizar, clique em "Add Key".

### Baixando os arquivos do repositório


1 - Crie uma nova pasta no desktop com o nome de sua preferência.

2 - Com o botão direito do mouse, clique sobre a pasta criada e selecione "Git Clone".

3 - Na nova tela, cole o endereço "git@git.pje.csjt.jus.br:infra/regional.git" no campo "URL".

4 - Ainda na nova tela, marque o campo "Load Putty Key", selecione o caminho aonde está a sua chave privada(`...`) e clique em `OK`

------
------

## Para plataforma UNIX
---

### Pré-requisitos

* Usuario cadastrado no GitLab (https://git.pje.csjt.jus.br/).

* Ferramenta pacote "git" instalado.



### Adicionar Chave Pública ao GitLab

1. Abra o terminal.

2. Como root (comando "sudo su -") utilize o comando "ssh-keygen" e precione ENTER.

3. Escolha o diretório aonde será salvo suas chaves ( local padrão: "/root/.ssh/" ).

4. Utilize o comando "cat" no arquivo de sua chave pública (caminho padrão "/root/.ssh/id_rsa.pub") para visualizar o hash de sua chave. "ex: 'cat /root/.ssh/id_rsa.pub' ".

5. Copie todo o texto exibido a partir de "ssh-rsa . . . ".

6. Faça o Login no GitLab.

7. Clique em "Profile settings" (perto da imagem do seu profile).

8. Vá na aba "SSH Keys".

9. Clique em "Add SSH Key".

10. Cole o texto copiado do  campo "Public key for pasting into OpenSSH authorized_keys file:" no espaço em branco "Key".
** Note que seu e-mail corporativo deve aparecer automaticamente no campo "Title", caso isso não aconteça clique em algum lugar fora do campo "key".
Observe se não há nenhum espaço ao final do seu e-mail corporativo. **

11. Para finalizar, clique em "Add Key".

### Clonar com protocolo ssh

1. Abra o terminal.

2. Clone o repositório na sua pasta atual.  
`git clone git@git.pje.csjt.jus.br:infra/regional.git`

3. Sempre atualize com as versões mais recente com git pull.  
`git pull`

### Clonar com protocolo https

1. Desabilitar verificação de certificados.  
    Para qualquer repositório:  
    `git config --global http.sslVerify false`  
    Ou para um repositório específico:  
    `git config http.sslVerify false`
2. Fazer download via https:  
`git clone https://git.pje.csjt.jus.br/infra/regional.git`


### Criar branch e commitar arquivos

1. Crie um novo branch para começar a trabalhar.  
`git checkout -b novo-branch`

2. Caso queira apenas trocar de branch, utilize o comando  
`git branch branch-alvo`

3. Crie e altere os arquivos que desejar. Depois, adicione os arquivos propostos. Exemplos:  
`git add <arquivos>`  
`git add *`

4. Faça um commit com o comentário das alterações.  
`git commit -m "comentários das alterações"`

5. Envie suas alterações ao servidor. Por exemplo, para enviar as mudanças feita no *branch-alvo*:  
`git push origin branch-alvo`

