# suapt

Чуть удобная версия `apt`, которая автоматически запускается
от рута.

Вот все команды:
| Команда | Описание |
|---------|----------|
| `-version` | версия `suapt` |
| `-su` | версии возможных програм, через которые команды выполняются от рута |
| `-sh` | показывает текущий шел (зачем?..) и говорит, как его добавить как функцию |
| `i`, `install`, `add` | `apt install` |
| `rm`, `remove`, `de`, `dd`, `del`, `delet`, `delete` | `apt remove` |
| `pg`, `pu`, `pr`, `purge` | `apt purge` |
| `l`, `ls`, `lst`, `list` | `apt list`, не от рута |
| `se`, `search` | `apt search`, не от рута |
| `up`, `update` | `apt update` |
| `upg`, `upgrade` | `apt upgrade` |
| `inf`, `info`, `sh`, `show` | `apt show`, не от рута |
| `rei`, `reinstall` | `apt reinstall` |
| `autopurge`, `autopg`, `autopr` | `apt autopurge` |
| `autorm`, `autoremove` | `apt autoremove` |

Все неизвесные аргументы, к примеру `suapt --version` выполняются от
рута.

## Установка

Два способа: скачать `suapt.bash` и кинуть его в `$PATH`, в `/usr/bin` к примеру. `chmod +x suapt.bash` и впринципе готово.

Второй способ: скачать его, кинуть куда угодно и написать в `.bashrc`:
`INCLUDE=1 source /path/to/suapt.bash`

## Остальные директории

М, лучше туда не смотреть, если не хочешь увидеть неудачную попытку
сделать что-то большее, чем алиас на `apt install`

