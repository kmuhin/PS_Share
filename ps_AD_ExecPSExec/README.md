# Выполнение удаленной команды на доменных компьютерах с сохранением вывода.

Вывод команды сохраняется в текстовый файл с именем компьютера.
В данном случае собираю информацию по сетевым интерфейсам:

    $cmd="ipconfig /all"

Список компьютеров получаю из AD. Авторизация в AD под текущим пользователем.
$SearchBaseComputers - скоп AD из которого беру имена машин
Пример:

    $SearchBaseComputers="OU=Workstations,OU=Domain Computers,DC=domain,DC=local"

## Утилита Марка Русиновича
Для исполнения команд на удаленной машине используется сторонняя программа известного разработчика Марка Русиновича
PsExec.exe
https://docs.microsoft.com/en-us/sysinternals/downloads/psexec

## Запуск

    dhcp.info.cmd
    
## Файлы

 - dhcp.info.cmd: wrapper для dhcp.info.ps1.
 - dhcp.info.ps1: сам скрипт.
 - history.yyyy.MM.dd: история команд.
 - dhcp.info.log: лог скрипта.
 
Copyright (c) 2014 Konstantin Mukhin
