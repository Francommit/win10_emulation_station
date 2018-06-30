Emulation Station configurado para Windows 10
======

Auto instalador para configurar corretamente o Emulation Station em uma máquina com Windows 10 64bit.

Com o aumento da pupularidade do Retropie, a configuração do Emulationstation em plataformas windows não
tem recebido muita atenção.

Eu já passei muitas noites tentando descobrir como configurar tudo corretamente para uma máquina Windows,
para finalmente deixar tudo certo. Dado a dor de cabeça que passei e a quantidade de amigos meus que me
pediram a mesma configuração, eu dedici juntar tudo e montar esse script powershell para outras pessoas usarem.

Destaques
------
- Usa uma versão atualizada do Emulation Station da branch do Raspery Pi
- Popula automaticamente emuladores com roms de domínio público
- Instala automaticamente um tema popular com suporte para a adição de favoritos
- Instalador inicial com menos de 20kb, já que é apenas um script
- Inclue um recuperador de informações de roms dentro da pasta de rom (execute %UserProfile%\.emulationstation\roms\scraper.exe)

Traduções
------
[English](README.md)

Passo-a-passo
------
1. Certifique-se que o chocolatey está instalado https://chocolatey.org/install
2. Certifique-se que o Powershell está configurado para "Set-executionpolicy Bypass" (execute o comando)
3. Execute prepare.ps1 em uma sessão administrativa Powershell
  (NOTA: Powershell pode reiniciar seu computador já que algumas bibliotecas requerem o reinício, se isto ocorrer, simplesmente re-execute depois de seu PC reiniciar)
4. Execute o Emulation Station and aproveite
5. Acesse suas ROMS aqui %UserProfile%\.emulationstation\roms

GIF da instalação:
![alt text](https://github.com/Francommit/github_gif_dump/blob/master/installation-instructions.gif?raw=true)



Possíveis problemas e soluções
------
- Se o seu controle não está funcionando no jogo, configure o Input no Retroarch (%UserProfile%\.emulationstation\systems\retroarch\retroarch.exe)
- Jogos de PS1 and PS2 não carregam a não ser que você tenha e inclua suas bios nas respectivas pastas (%UserProfile%\.emulationstation\systems\epsxe\bios e %UserProfile%\.emulationstation\systems\pcsx2\bios)
- PS1 e PS2 também requerem configuração manual para os controles(%UserProfile%\.emulationstation\systems\epsxe\ePSXe.exe e %UserProfile%\.emulationstation\systems\pcsx2\pcsx2.exe)
- Se o script falhar por qualquer razão, apague o conteúdo da pasta %UserProfile%\.emulationstation e tente novamente.
- O Emulation Station pode travar quando você retorna para ele depois de um programa externo, certifique-se que sua placa de vídeo possui os drivers atualizados.
- Se ao executar uma rom no Retroarch, retornar para o Emulationstation, você provavelmente está em uma versão 32-bit do Windows e precisará de outros cores (DLLs do Retroarch).
- Comandos Powershell podem falhar, certifique-se que sua sessão está em modo administrador.
- Se o Powershell reclamar da sintaxe, você provavelmente está executando uma versão do Powershell abaixo da 5. Execute 'choco install powershell -y' para atualizar.
- Gamecube precisa de umas configurações - https://www.libretro.com/index.php/new-core-dolphin-windowslinux-alpha-release/

Agradecimentos Especiais
------
- jrassa pela sua versão atualizada da compilação do Emulation Station - https://github.com/jrassa/EmulationStation
- Nesworld por suas ROMs livres de NES - http://www.nesworld.com/
- Libretro por sua versão do Retroarch - https://www.libretro.com/
- dtgm por manter o pacote chocolatey do Emulation Station https://chocolatey.org/packages/emulationstation
- OpenEmu por seu trabalho na coleção de rom livres https://github.com/OpenEmu/OpenEmu-Update
- recalbox por seus temas https://github.com/recalbox/recalbox-themes
- sselph por seu maravilhoso recuperador de informações de roms https://github.com/sselph/scraper
- PRElias pela tradução em Português do Brasil - http://paulorobertoelias.com
