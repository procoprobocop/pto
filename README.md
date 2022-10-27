_#Скрипт для автоматической установки и настройки Linux_

_#для ГУ "ПТО УД ЯНАО"
__________________________________________________________________________________

_#Подготовка к запуску скриптов_

1. В контроллере домена, в папке Computers удалите настраиваемый компьютер если он там есть (иначе будут проблемы с добавлением в домен).

2. Если будет ставиться **VipNet** заранее скиньте на флешку **dst-файл** и секретный ключ, если будет ставиться **Lotus**, то заранее скиньте на флешку **id-файл** и **desktop8.ndk** (их нужно подменить в папке _**C:\Lotus\Notes\Data**_ чтобы не настраивать РМ заново).

3. Откройте терминал и введите:

**cd /usr/share**
**git clone https://github.com/procoprobocop/pto.git**
**cd pto/** 
**chmod ugo+x** ***.sh**

_#Вы скачали скрипт и дали ему права на выполнение. Теперь можно переходить к их запуску_

___________________________________________________________________________________

#Запуск скриптоа

4. Введите в терминале:

**./ptoscript_1.sh**

_#Будет выполнен запуск скрипта, после чего произойдёт перезагрузка_

5. Откройте терминал и введите:

**cd /usr/share**
**./ptoscript_2.sh**

_#Некоторые настройки, например пользователя в Spark или 1C придётся донастраивать самостоятельно._
_____________________________________________________________________________________

_#P.S: Запускать один скрипт дважды может только Чак Норрис!))_

