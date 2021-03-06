# Инструкция по установке Manjaro на файловую систему btrfs при помощи Architect
Основой данной заметки является статья: [Архитектор с (Кили)Манджаро и btrfs](https://maxper.ru/2017/12/24/%D0%B0%D1%80%D1%85%D0%B8%D1%82%D0%B5%D0%BA%D1%82%D0%BE%D1%80-%D1%81-%D0%BA%D0%B8%D0%BB%D0%B8%D0%BC%D0%B0%D0%BD%D0%B4%D0%B6%D0%B0%D1%80%D0%BE-%D0%B8-btrfs/)

## Содержание

## Введение
В данной заметке будет описана установка дистрибутива Manjaro 20.2 c минимальным окружением рабочего стола KDE. В качестве носителя будет использоваться SSD диск и BTFS в качестве файловой системы

## Подготовка диска
Установка будет производиться в системе с UEFI поэтому размечаем диск в соответствии со следующей таблицей:

| Путь      | Тип              | Размер            | Описание                |
|-----------|------------------|-------------------|-------------------------|
| /dev/sdX1 | EFI              | 512 - 1024 МБ     | Загрузочные раздел UEFI |
| /dev/sdX2 | swap             | 2 ГБ - размер ОЗУ | SWAP раздел             |
| /dev/sdX3 | Linux filesystem | оставшееся        | Раздел под систему      |

Разметку диска будем выполнять при помощи утилиты `fdisk`. 


<!--stackedit_data:
eyJoaXN0b3J5IjpbMTQ0NDQyMjU2OCwxODI2MjI3NDYyLC02MD
YyOTExMDksLTIwMzMyNTIzNzddfQ==
-->